import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/faq_response.dart';
import '../models/requests/create_faq_request.dart';
import '../models/requests/update_faq_request.dart';
import '../models/filters/faq_query_filter.dart';

/// FAQ service using new generic CRUD pattern
class FaqService extends CrudService<
    FaqResponse,
    CreateFaqRequest,
    UpdateFaqRequest,
    FaqQueryFilter> {
  FaqService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/faq',
          responseParser: FaqResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateFaqRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateFaqRequest request) =>
      request.toJson();
}
