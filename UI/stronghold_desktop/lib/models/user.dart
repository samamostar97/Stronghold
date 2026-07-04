class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? streetAddress;
  final int? cityId;
  final String? cityName;
  final bool hasImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.streetAddress,
    this.cityId,
    this.cityName,
    required this.hasImage,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        streetAddress: json['streetAddress'] as String?,
        cityId: json['cityId'] as int?,
        cityName: json['cityName'] as String?,
        hasImage: json['hasImage'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
