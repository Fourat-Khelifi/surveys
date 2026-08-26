/// A row from `public.profiles`, joined with the email from the auth session.
///
/// The name lives in the database rather than in `auth.users.raw_user_meta_data`
/// so it can be joined to responses and validated by a constraint. Metadata is
/// only the seed the signup trigger reads once.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String? fullName;
  final String email;

  factory UserProfile.fromJson(Map<String, dynamic> json, {String email = ''}) {
    final name = (json['full_name'] as String?)?.trim();
    return UserProfile(
      id: json['id'].toString(),
      fullName: (name == null || name.isEmpty) ? null : name,
      email: email,
    );
  }

  /// What to greet the user with. Falls back to the local part of their email
  /// rather than a generic "User", which reads like the app forgot who they are.
  String get displayName {
    if (fullName != null) return fullName!;
    final local = email.split('@').first.trim();
    return local.isEmpty ? 'there' : local;
  }

  /// The first name only, for greetings where the full name is too long.
  String get firstName => displayName.split(RegExp(r'\s+')).first;

  /// Up to two letters for the avatar. "Ada Lovelace" gives AL, "Ada" gives A.
  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  UserProfile copyWith({String? fullName}) =>
      UserProfile(id: id, fullName: fullName ?? this.fullName, email: email);
}

/// `String.characters` needs the characters package for full grapheme support;
/// this keeps the dependency out for the single use above while still not
/// splitting a surrogate pair in half.
extension on String {
  Iterable<String> get characters => runes.map((r) => String.fromCharCode(r));
}
