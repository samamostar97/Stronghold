import '../api/api_client.dart';
import '../models/common/date_time_utils.dart';
import '../models/common/paged_result.dart';
import '../models/responses/trainer_response.dart';
import '../models/requests/create_trainer_request.dart';
import '../models/requests/update_trainer_request.dart';
import '../models/filters/trainer_query_filter.dart';

class TrainerService {
  final ApiClient _client;
  static const String _path = '/api/trainers';

  TrainerService(this._client);

  Future<PagedResult<TrainerResponse>> getAll(TrainerQueryFilter filter) {
    return _client.get<PagedResult<TrainerResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, TrainerResponse.fromJson),
    );
  }

  Future<List<TrainerResponse>> getAllUnpaged(TrainerQueryFilter filter) {
    return _client.get<List<TrainerResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => TrainerResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<TrainerResponse> getById(int id) {
    return _client.get<TrainerResponse>(
      '$_path/$id',
      parser: (json) => TrainerResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateTrainerRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateTrainerRequest request) {
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

  Future<List<int>> getAvailableHours(int trainerId, DateTime date) {
    return _client.get<List<int>>(
      '$_path/$trainerId/available-hours',
      queryParameters: {'date': DateTimeUtils.toApiDate(date)},
      parser: (json) => (json as List).map((e) => (e as num).toInt()).toList(),
    );
  }
}
