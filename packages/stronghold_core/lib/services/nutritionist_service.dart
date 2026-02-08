import '../api/api_client.dart';
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
  NutritionistService(ApiClient client)
      : super(
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
}
