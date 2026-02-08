import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/supplement_response.dart';
import '../models/requests/create_supplement_request.dart';
import '../models/requests/update_supplement_request.dart';
import '../models/filters/supplement_query_filter.dart';

/// Supplement service using new generic CRUD pattern
/// Old: 100+ LOC in supplements_api.dart with duplicate _headers()
/// New: ~20 LOC, no duplication
class SupplementService extends CrudServiceWithImage<
    SupplementResponse,
    CreateSupplementRequest,
    UpdateSupplementRequest,
    SupplementQueryFilter> {
  SupplementService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/supplements',
          responseParser: SupplementResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateSupplementRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateSupplementRequest request) =>
      request.toJson();
}
