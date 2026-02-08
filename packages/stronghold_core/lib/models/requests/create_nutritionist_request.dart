/// Matches backend CreateNutritionistRequest exactly
class CreateNutritionistRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const CreateNutritionistRequest({
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
