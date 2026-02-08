/// Matches backend ReviewResponse
class ReviewResponse {
  final int id;
  final int userId;
  final String? userName;
  final int supplementId;
  final String? supplementName;
  final int rating;
  final String? comment;

  const ReviewResponse({
    required this.id,
    required this.userId,
    this.userName,
    required this.supplementId,
    this.supplementName,
    required this.rating,
    this.comment,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      userName: json['userName'] as String?,
      supplementId: (json['supplementId'] ?? 0) as int,
      supplementName: json['supplementName'] as String?,
      rating: (json['rating'] ?? 0) as int,
      comment: json['comment'] as String?,
    );
  }
}
