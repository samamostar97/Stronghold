class PurchasedSupplement {
  final int id;
  final String name;

  PurchasedSupplement({required this.id, required this.name});

  factory PurchasedSupplement.fromJson(Map<String, dynamic> json) {
    return PurchasedSupplement(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Review {
  final int id;
  final String supplementName;
  final int rating;
  final String? comment;

  Review({
    required this.id,
    required this.supplementName,
    required this.rating,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      supplementName: json['supplementName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}
