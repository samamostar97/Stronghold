/// Matches backend SupplementResponse
class SupplementResponse {
  final int id;
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final String? supplementCategoryName;
  final int supplierId;
  final String? supplierName;
  final String? imageUrl;

  const SupplementResponse({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.supplementCategoryId,
    this.supplementCategoryName,
    required this.supplierId,
    this.supplierName,
    this.imageUrl,
  });

  factory SupplementResponse.fromJson(Map<String, dynamic> json) {
    return SupplementResponse(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
      description: json['description'] as String?,
      supplementCategoryId: (json['supplementCategoryId'] ?? 0) as int,
      supplementCategoryName: json['supplementCategoryName'] as String?,
      supplierId: (json['supplierId'] ?? 0) as int,
      supplierName: json['supplierName'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['supplementImageUrl'] as String?,
    );
  }
}
