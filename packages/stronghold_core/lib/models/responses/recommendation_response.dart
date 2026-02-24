/// Supplement recommendation response
class RecommendationResponse {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String categoryName;
  final String supplierName;
  final double averageRating;
  final int reviewCount;
  final String recommendationReason;

  const RecommendationResponse({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.categoryName,
    required this.supplierName,
    required this.averageRating,
    required this.reviewCount,
    required this.recommendationReason,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      categoryName: json['categoryName'] as String,
      supplierName: json['supplierName'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      recommendationReason: json['recommendationReason'] as String,
    );
  }
}
