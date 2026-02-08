/// Matches backend CreateUserRequest exactly
class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final int gender;
  final String password;

  const CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'password': password,
      };
}
