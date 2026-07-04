/// Profil clana - polja koja mobilna aplikacija prikazuje i ureduje.
class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String? streetAddress;
  final int? cityId;
  final String? cityName;
  final bool hasImage;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    this.streetAddress,
    this.cityId,
    this.cityName,
    required this.hasImage,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        streetAddress: json['streetAddress'] as String?,
        cityId: json['cityId'] as int?,
        cityName: json['cityName'] as String?,
        hasImage: json['hasImage'] as bool,
      );
}
