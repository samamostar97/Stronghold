/// Matches backend TrainerResponse exactly
class TrainerResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const TrainerResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory TrainerResponse.fromJson(Map<String, dynamic> json) {
    return TrainerResponse(
      id: (json['id'] ?? 0) as int,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
    );
  }

  /// Full name helper
  String get fullName => '$firstName $lastName';
}
