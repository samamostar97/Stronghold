class Supplement {
  final int id;
  final String name;
  final double price;
  final String description;
  final int categoryId;
  final String categoryName;
  final int supplierId;
  final String supplierName;
  final int stockQuantity;
  final bool hasImage;
  final double averageRating;
  final int reviewCount;

  Supplement({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.supplierId,
    required this.supplierName,
    required this.stockQuantity,
    required this.hasImage,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) => Supplement(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        categoryId: json['categoryId'] as int,
        categoryName: json['categoryName'] as String,
        supplierId: json['supplierId'] as int,
        supplierName: json['supplierName'] as String,
        stockQuantity: json['stockQuantity'] as int,
        hasImage: json['hasImage'] as bool,
        averageRating: (json['averageRating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
      );
}
