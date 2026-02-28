import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/supplement_category_response.dart';
import '../models/requests/create_supplement_category_request.dart';
import '../models/requests/update_supplement_category_request.dart';
import '../models/filters/supplement_category_query_filter.dart';

class SupplementCategoryService {
  final ApiClient _client;
  static const String _path = '/api/supplement-categories';

  SupplementCategoryService(this._client);

  Future<PagedResult<SupplementCategoryResponse>> getAll(SupplementCategoryQueryFilter filter) {
    return _client.get<PagedResult<SupplementCategoryResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, SupplementCategoryResponse.fromJson),
    );
  }

  Future<List<SupplementCategoryResponse>> getAllUnpaged(SupplementCategoryQueryFilter filter) {
    return _client.get<List<SupplementCategoryResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => SupplementCategoryResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<SupplementCategoryResponse> getById(int id) {
    return _client.get<SupplementCategoryResponse>(
      '$_path/$id',
      parser: (json) => SupplementCategoryResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateSupplementCategoryRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateSupplementCategoryRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}
