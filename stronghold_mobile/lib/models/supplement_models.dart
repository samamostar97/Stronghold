class Supplement {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;

  Supplement({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['supplementCategoryId'] as int,
      categoryName: json['supplementCategoryName'] as String,
    );
  }
}

class SupplementCategory {
  final int id;
  final String name;

  SupplementCategory({
    required this.id,
    required this.name,
  });

  factory SupplementCategory.fromJson(Map<String, dynamic> json) {
    return SupplementCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class SupplementReview {
  final int id;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  SupplementReview({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory SupplementReview.fromJson(Map<String, dynamic> json) {
    return SupplementReview(
      id: json['id'] as int,
      userName: json['userName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
  });
}
