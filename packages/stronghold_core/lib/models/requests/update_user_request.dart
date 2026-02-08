/// Matches backend UpdateUserRequest exactly
class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? password;

  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (username != null) map['username'] = username;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (password != null) map['password'] = password;
    return map;
  }
}
