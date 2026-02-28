import '../api/api_client.dart';
import '../models/common/date_time_utils.dart';
import '../models/common/paged_result.dart';
import '../models/responses/nutritionist_response.dart';
import '../models/requests/create_nutritionist_request.dart';
import '../models/requests/update_nutritionist_request.dart';
import '../models/filters/nutritionist_query_filter.dart';

class NutritionistService {
  final ApiClient _client;
  static const String _path = '/api/nutritionists';

  NutritionistService(this._client);

  Future<PagedResult<NutritionistResponse>> getAll(NutritionistQueryFilter filter) {
    return _client.get<PagedResult<NutritionistResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, NutritionistResponse.fromJson),
    );
  }

  Future<List<NutritionistResponse>> getAllUnpaged(NutritionistQueryFilter filter) {
    return _client.get<List<NutritionistResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => NutritionistResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<NutritionistResponse> getById(int id) {
    return _client.get<NutritionistResponse>(
      '$_path/$id',
      parser: (json) => NutritionistResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateNutritionistRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateNutritionistRequest request) {
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

  Future<List<int>> getAvailableHours(int nutritionistId, DateTime date) {
    return _client.get<List<int>>(
      '$_path/$nutritionistId/available-hours',
      queryParameters: {'date': DateTimeUtils.toApiDate(date)},
      parser: (json) => (json as List).map((e) => (e as num).toInt()).toList(),
    );
  }
}
