class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      };
}

class AuthResponse {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String token;
  final bool hasActiveMembership;

  AuthResponse({
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

  AuthResponse copyWithImage(String? imageUrl) {
    return AuthResponse(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profileImageUrl: imageUrl,
      token: token,
      hasActiveMembership: hasActiveMembership,
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
