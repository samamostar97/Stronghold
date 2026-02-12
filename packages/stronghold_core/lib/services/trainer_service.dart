import '../api/api_client.dart';
import '../models/common/date_time_utils.dart';
import 'crud_service.dart';
import '../models/responses/trainer_response.dart';
import '../models/requests/create_trainer_request.dart';
import '../models/requests/update_trainer_request.dart';
import '../models/filters/trainer_query_filter.dart';

/// Trainer service using generic CRUD pattern
class TrainerService extends CrudService<
    TrainerResponse,
    CreateTrainerRequest,
    UpdateTrainerRequest,
    TrainerQueryFilter> {
  final ApiClient _apiClient;

  TrainerService(ApiClient client)
      : _apiClient = client,
        super(
          client: client,
          basePath: '/api/trainer',
          responseParser: TrainerResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateTrainerRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateTrainerRequest request) =>
      request.toJson();

  /// Get available hours for a trainer on a specific date
  Future<List<int>> getAvailableHours(int trainerId, DateTime date) async {
    return _apiClient.get<List<int>>(
      '/api/trainer/$trainerId/available-hours',
      queryParameters: {'date': DateTimeUtils.toApiDate(date)},
      parser: (json) =>
          (json as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );
  }
}
