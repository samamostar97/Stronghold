class UpsertAddressRequest {
  final String street;
  final String city;
  final String postalCode;
  final String country;

  UpsertAddressRequest({
    required this.street,
    required this.city,
    required this.postalCode,
    this.country = 'Bosna i Hercegovina',
  });

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'country': country,
      };
}
