/// Auth response for member login/register
class AuthResponse {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String token;
  final bool hasActiveMembership;

  const AuthResponse({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.token,
    required this.hasActiveMembership,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      token: json['token'] as String,
      hasActiveMembership: json['hasActiveMembership'] as bool? ?? false,
    );
  }

  AuthResponse copyWith({
    int? userId,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? profileImageUrl,
    String? token,
    bool? hasActiveMembership,
    bool clearProfileImage = false,
  }) {
    return AuthResponse(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl:
          clearProfileImage ? null : (profileImageUrl ?? this.profileImageUrl),
      token: token ?? this.token,
      hasActiveMembership: hasActiveMembership ?? this.hasActiveMembership,
    );
  }

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    if (firstName.isNotEmpty) {
      return firstName;
    }
    return username;
  }
}
