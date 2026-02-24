import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/user_review_response.dart';
import '../models/responses/purchased_supplement_response.dart';

/// User-facing review service (member's own reviews)
class UserReviewService {
  final ApiClient _client;

  UserReviewService(this._client);

  /// Get current user's reviews (paginated)
  Future<PagedResult<UserReviewResponse>> getMyReviews({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _client.get<PagedResult<UserReviewResponse>>(
      '/api/reviews/my',
      queryParameters: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        UserReviewResponse.fromJson,
      ),
    );
  }

  /// Get supplements available for review (paginated)
  Future<PagedResult<PurchasedSupplementResponse>> getAvailableSupplements({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _client.get<PagedResult<PurchasedSupplementResponse>>(
      '/api/reviews/available-supplements',
      queryParameters: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        PurchasedSupplementResponse.fromJson,
      ),
    );
  }

  /// Create a new review
  Future<void> create({
    required int supplementId,
    required int rating,
    String? comment,
  }) async {
    await _client.post<void>(
      '/api/reviews',
      body: {
        'supplementId': supplementId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      parser: (_) {},
    );
  }

  /// Delete a review
  Future<void> delete(int id) async {
    await _client.delete('/api/reviews/$id');
  }
}
