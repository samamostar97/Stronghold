class AddressResponse {
  final int id;
  final String street;
  final String city;
  final String postalCode;
  final String country;

  AddressResponse({
    required this.id,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      id: json['id'] as int,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? 'Bosna i Hercegovina',
    );
  }
}
