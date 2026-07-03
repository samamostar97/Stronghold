class Supplier {
  final int id;
  final String name;
  final String contactEmail;
  final String contactPhone;

  Supplier({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int,
        name: json['name'] as String,
        contactEmail: json['contactEmail'] as String,
        contactPhone: json['contactPhone'] as String,
      );
}
