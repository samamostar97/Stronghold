/// Review on a specific supplement (public-facing)
class SupplementReviewResponse {
  final int id;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const SupplementReviewResponse({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory SupplementReviewResponse.fromJson(Map<String, dynamic> json) {
    return SupplementReviewResponse(
      id: json['id'] as int,
      userName: json['userName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
