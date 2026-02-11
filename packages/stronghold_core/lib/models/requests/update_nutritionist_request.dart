/// Matches backend UpdateNutritionistRequest exactly
class UpdateNutritionistRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const UpdateNutritionistRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      };
}
