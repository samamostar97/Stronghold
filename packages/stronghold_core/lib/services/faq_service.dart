import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/faq_response.dart';
import '../models/requests/create_faq_request.dart';
import '../models/requests/update_faq_request.dart';
import '../models/filters/faq_query_filter.dart';

class FaqService {
  final ApiClient _client;
  static const String _path = '/api/faqs';

  FaqService(this._client);

  Future<PagedResult<FaqResponse>> getAll(FaqQueryFilter filter) {
    return _client.get<PagedResult<FaqResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, FaqResponse.fromJson),
    );
  }

  Future<List<FaqResponse>> getAllUnpaged(FaqQueryFilter filter) {
    return _client.get<List<FaqResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => FaqResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<FaqResponse> getById(int id) {
    return _client.get<FaqResponse>(
      '$_path/$id',
      parser: (json) => FaqResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateFaqRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateFaqRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}
