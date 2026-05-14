import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  AuthService();

  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName, 'earnings': 0},
      );

      if (response.user == null) {
        throw Exception("Sign up failed");
      }

      debugPrint(
        'User signed up: ${response.user!.email}, fullName: $fullName',
      );
      return response;
    } catch (e) {
      debugPrint("Error during sign up: $e");
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception("Sign in failed");
      }
      return response;
    } catch (e) {
      debugPrint("Error during sign in: $e");
      rethrow;
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

  User? get currentUser => _client.auth.currentUser;
}
