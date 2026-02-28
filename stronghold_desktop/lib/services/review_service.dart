import 'package:stronghold_core/stronghold_core.dart';

/// Review service - read-only with delete support (no create/update)
/// Matches backend AdminReviewController pattern
class ReviewService {
  final ApiClient _client;
  static const String _basePath = '/api/reviews';

  ReviewService(this._client);

  /// Get paginated list with server-side filtering and sorting
  Future<PagedResult<ReviewResponse>> getAll(ReviewQueryFilter filter) async {
    return _client.get<PagedResult<ReviewResponse>>(
      _basePath,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        ReviewResponse.fromJson,
      ),
    );
  }

  /// Get single review by ID
  Future<ReviewResponse> getById(int id) async {
    return _client.get<ReviewResponse>(
      '$_basePath/$id',
      parser: (json) => ReviewResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete review by ID
  Future<void> delete(int id) async {
    await _client.delete('$_basePath/$id');
  }
}
