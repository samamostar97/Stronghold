class ReviewDTO {
  final int id;
  final int userId;
  final String userName;
  final int supplementId;
  final String supplementName;
  final int rating;
  final String? comment;


  const ReviewDTO({
    required this.id,
    required this.userId,
    required this.userName,
    required this.supplementId,
    required this.supplementName,
    required this.rating,
    this.comment,
  });

  factory ReviewDTO.fromJson(Map<String, dynamic> json) {
    return ReviewDTO(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      userName: (json['userName'] ?? '') as String,
      supplementId: (json['supplementId'] ?? 0) as int,
      supplementName: (json['supplementName'] ?? '') as String,
      rating: (json['rating'] ?? 0) as int,
      comment: (json['comment'] ?? '') as String?,
    );
  }
}



class PagedReviewsResult {
  final List<ReviewDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedReviewsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedReviewsResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => ReviewDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <ReviewDTO>[];

    return PagedReviewsResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
