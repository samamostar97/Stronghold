/// Matches backend UpdateNutritionistRequest exactly
class UpdateNutritionistRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;

  const UpdateNutritionistRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    return map;
  }
}
