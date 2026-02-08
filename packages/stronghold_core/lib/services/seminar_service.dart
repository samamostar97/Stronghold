import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/seminar_response.dart';
import '../models/requests/create_seminar_request.dart';
import '../models/requests/update_seminar_request.dart';
import '../models/filters/seminar_query_filter.dart';

/// Seminar service using generic CRUD pattern
class SeminarService extends CrudService<
    SeminarResponse,
    CreateSeminarRequest,
    UpdateSeminarRequest,
    SeminarQueryFilter> {
  SeminarService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/seminar',
          responseParser: SeminarResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateSeminarRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateSeminarRequest request) =>
      request.toJson();
}
