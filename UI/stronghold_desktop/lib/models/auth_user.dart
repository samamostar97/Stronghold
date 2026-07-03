/// Prijavljeni administrator - samo polja koja desktop stvarno koristi.
class AuthUser {
  final int userId;
  final String username;
  final String firstName;
  final String role;
  final String accessToken;
  final String refreshToken;

  AuthUser({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'] as int,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        role: json['role'] as String,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
