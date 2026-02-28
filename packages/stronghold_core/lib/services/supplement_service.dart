import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/supplement_response.dart';
import '../models/requests/create_supplement_request.dart';
import '../models/requests/update_supplement_request.dart';
import '../models/filters/supplement_query_filter.dart';
import '../models/responses/supplement_review_response.dart';

class SupplementService {
  final ApiClient _client;
  static const String _path = '/api/supplements';

  SupplementService(this._client);

  Future<PagedResult<SupplementResponse>> getAll(SupplementQueryFilter filter) {
    return _client.get<PagedResult<SupplementResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, SupplementResponse.fromJson),
    );
  }

  Future<List<SupplementResponse>> getAllUnpaged(SupplementQueryFilter filter) {
    return _client.get<List<SupplementResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => SupplementResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<SupplementResponse> getById(int id) {
    return _client.get<SupplementResponse>(
      '$_path/$id',
      parser: (json) => SupplementResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateSupplementRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateSupplementRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');

  Future<void> uploadImage(int id, String filePath) {
    return _client.uploadFile<void>('$_path/$id/image', filePath, 'file', parser: (_) {});
  }

  Future<void> deleteImage(int id) => _client.delete('$_path/$id/image');

  Future<List<SupplementReviewResponse>> getReviews(int supplementId) {
    return _client.get<List<SupplementReviewResponse>>(
      '$_path/$supplementId/reviews',
      parser: (json) => (json as List).map((j) => SupplementReviewResponse.fromJson(j as Map<String, dynamic>)).toList(),
    );
  }
}
