/// Matches backend UserResponse
class UserResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final int gender;
  final String? profileImageUrl;

  const UserResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.profileImageUrl,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: (json['id'] ?? 0) as int,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      gender: (json['gender'] ?? 0) as int,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  /// Helper to get full name
  String get fullName => '$firstName $lastName';

  /// Helper to get gender display text
  String get genderDisplay {
    switch (gender) {
      case 0:
        return 'Muški';
      case 1:
        return 'Ženski';
      case 2:
        return 'Ostalo';
      default:
        return '-';
    }
  }
}
