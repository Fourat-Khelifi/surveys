import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/core/models/user_profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  AuthService();

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // `data` lands in auth.users.raw_user_meta_data, which the user can
      // rewrite at any time via auth.updateUser(). Only ever put things here
      // that it is harmless for the user to control — a name qualifies, a
      // points balance emphatically does not.
      //
      // This is a seed, not a home: the `on_auth_user_created` trigger copies
      // it into `profiles.full_name`, which is the source of truth from then
      // on. `display_name` is sent alongside for accounts and tooling that
      // still read the older key.
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'display_name': fullName},
      );

      if (response.user == null) {
        throw const AuthFailure("Sign up failed. Please try again.");
      }

      debugPrint(
        'User signed up: ${response.user!.email}, fullName: $fullName',
      );
      return response;
    } on AuthException catch (e) {
      debugPrint("Error during sign up: $e");
      throw AuthFailure(describeAuthError(e));
    }
  }

  /// The signed-in user's profile row, or null when signed out.
  ///
  /// Falls back to a metadata-derived profile if the row is somehow missing —
  /// the trigger should always create one, but a profile screen that renders
  /// nothing is a worse failure than one showing a slightly stale name.
  Future<UserProfile?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select('id, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        return UserProfile(
          id: user.id,
          fullName:
              (user.userMetadata?['full_name'] ??
                      user.userMetadata?['display_name'])
                  as String?,
          email: user.email ?? '',
        );
      }

      return UserProfile.fromJson(data, email: user.email ?? '');
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      rethrow;
    }
  }

  /// Renames the signed-in user. Writes to `profiles`, which is the source of
  /// truth, and mirrors into auth metadata so the two do not disagree.
  Future<UserProfile> updateFullName(String fullName) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure("You need to be signed in to do that.");
    }

    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      throw const AuthFailure("Please enter a name.");
    }
    if (trimmed.length > 80) {
      throw const AuthFailure("That name is too long — 80 characters at most.");
    }

    try {
      final data = await _client
          .from('profiles')
          .update({'full_name': trimmed})
          .eq('id', user.id)
          .select('id, full_name')
          .single();

      // Best effort: the profile row is what the app reads, so a failure to
      // mirror into metadata must not fail the rename.
      try {
        await _client.auth.updateUser(
          UserAttributes(data: {'full_name': trimmed, 'display_name': trimmed}),
        );
      } catch (e) {
        debugPrint("Profile updated but metadata mirror failed: $e");
      }

      return UserProfile.fromJson(data, email: user.email ?? '');
    } on PostgrestException catch (e) {
      debugPrint("Error updating name: ${e.code} ${e.message}");
      // The CHECK constraint is the only thing that can reject a trimmed,
      // length-checked name here.
      throw const AuthFailure("That name isn't valid. Try a different one.");
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthFailure("Sign in failed. Please try again.");
      }
      return response;
    } on AuthException catch (e) {
      debugPrint("Error during sign in: $e");
      if (isEmailNotConfirmed(e)) {
        throw const EmailNotConfirmedFailure(
          "Please confirm your email before signing in. Check your inbox for the confirmation link.",
        );
      }
      throw AuthFailure(describeAuthError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint("Error during sign out: $e");
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      debugPrint("Error during password reset request: $e");
      throw AuthFailure(describeAuthError(e));
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      debugPrint("Error during resend confirmation: $e");
      throw AuthFailure(describeAuthError(e));
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      debugPrint("Error during password update: $e");
      throw AuthFailure(describeAuthError(e));
    }
  }
}

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

class EmailNotConfirmedFailure extends AuthFailure {
  const EmailNotConfirmedFailure(super.message);
}

bool isEmailNotConfirmed(Object error) {
  final message = _errorMessage(error).toLowerCase();
  return message.contains('not confirmed') ||
      message.contains("email isn't confirmed") ||
      message.contains('email_not_confirmed');
}

String describeAuthError(Object error) {
  if (error is AuthFailure) return error.message;

  if (error is AuthWeakPasswordException) {
    if (error.reasons.isNotEmpty) {
      final reasons = error.reasons
          .map((r) => r.toString().replaceAll('_', ' '))
          .join(', ');
      return "Weak password: needs $reasons.";
    }
    return error.message;
  }

  // Only treat it as a connectivity problem when the request never
  // completed (no status code). Supabase also wraps real API errors
  // (e.g. 500s) in this exception type.
  if (error is AuthRetryableFetchException && error.statusCode == null) {
    return "Can't reach the server. Check your connection and try again.";
  }

  if (error is AuthException) {
    final raw = _errorMessage(error);
    final msg = raw.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return "Incorrect email or password.";
    }
    if (msg.contains('already registered')) {
      return "An account with this email already exists.";
    }
    if (msg.contains('not confirmed')) {
      return "Please confirm your email before signing in. Check your inbox for the confirmation link.";
    }
    if (msg.contains('rate limit')) {
      return "Too many attempts. Please wait a moment and try again.";
    }
    if (msg.contains('sending confirmation email') ||
        msg.contains('error sending')) {
      return "Sign-up worked, but the confirmation email couldn't be sent. The Supabase project's email/SMTP settings need attention.";
    }
    if (msg.contains('valid email')) {
      return "Please enter a valid email address.";
    }
    if (msg.contains('password should be at least')) {
      return raw;
    }
    if (msg.contains('signup requires a valid password')) {
      return "Please enter a stronger password (at least 6 characters).";
    }
    if (msg.contains('user not found') || msg.contains('user not exist')) {
      return "No account found with this email.";
    }
    if (raw.trim().isNotEmpty && !raw.contains('Exception')) {
      return raw;
    }
  }

  return "Something went wrong. Please try again.";
}

String _errorMessage(Object error) {
  if (error is AuthException) return error.message;
  return error.toString();
}
