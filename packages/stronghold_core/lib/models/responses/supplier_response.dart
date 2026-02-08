/// Matches backend SupplierResponse
class SupplierResponse {
  final int id;
  final String name;
  final String? website;

  const SupplierResponse({
    required this.id,
    required this.name,
    this.website,
  });

  factory SupplierResponse.fromJson(Map<String, dynamic> json) {
    return SupplierResponse(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      website: json['website'] as String?,
    );
  }
}
