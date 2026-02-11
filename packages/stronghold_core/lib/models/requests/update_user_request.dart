/// Matches backend UpdateUserRequest exactly
class UpdateUserRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;

  const UpdateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
      };
}
