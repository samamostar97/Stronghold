import '../api/api_client.dart';
import '../models/common/appointment_date_utils.dart';
import 'crud_service.dart';
import '../models/responses/nutritionist_response.dart';
import '../models/requests/create_nutritionist_request.dart';
import '../models/requests/update_nutritionist_request.dart';
import '../models/filters/nutritionist_query_filter.dart';

/// Nutritionist service using generic CRUD pattern
class NutritionistService extends CrudService<
    NutritionistResponse,
    CreateNutritionistRequest,
    UpdateNutritionistRequest,
    NutritionistQueryFilter> {
  final ApiClient _apiClient;

  NutritionistService(ApiClient client)
      : _apiClient = client,
        super(
          client: client,
          basePath: '/api/nutritionist',
          responseParser: NutritionistResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateNutritionistRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateNutritionistRequest request) =>
      request.toJson();

  /// Get available hours for a nutritionist on a specific date
  Future<List<int>> getAvailableHours(
      int nutritionistId, DateTime date) async {
    return _apiClient.get<List<int>>(
      '/api/nutritionist/$nutritionistId/available-hours',
      queryParameters: {'date': AppointmentDateUtils.toApiDate(date)},
      parser: (json) =>
          (json as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );
  }
}
