/// Prijavljeni clan teretane - polja koja mobilna aplikacija koristi.
class Member {
  final int userId;
  final String firstName;
  final String lastName;
  final String role;
  final String accessToken;
  final String refreshToken;

  Member({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  String get fullName => '$firstName $lastName';

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        userId: json['userId'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
