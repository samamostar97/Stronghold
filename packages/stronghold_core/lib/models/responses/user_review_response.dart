/// User-facing review response (member's own reviews)
class UserReviewResponse {
  final int id;
  final String supplementName;
  final int rating;
  final String? comment;

  const UserReviewResponse({
    required this.id,
    required this.supplementName,
    required this.rating,
    this.comment,
  });

  factory UserReviewResponse.fromJson(Map<String, dynamic> json) {
    return UserReviewResponse(
      id: json['id'] as int,
      supplementName: json['supplementName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}
