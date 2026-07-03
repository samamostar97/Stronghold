class Review {
  final int id;
  final int supplementId;
  final String supplementName;
  final String userFullName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.supplementId,
    required this.supplementName,
    required this.userFullName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        supplementId: json['supplementId'] as int,
        supplementName: json['supplementName'] as String,
        userFullName: json['userFullName'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
