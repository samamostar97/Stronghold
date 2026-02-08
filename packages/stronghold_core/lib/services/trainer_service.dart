import '../api/api_client.dart';
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
  TrainerService(ApiClient client)
      : super(
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
}
