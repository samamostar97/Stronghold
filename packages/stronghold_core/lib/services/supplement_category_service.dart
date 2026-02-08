import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/supplement_category_response.dart';
import '../models/requests/create_supplement_category_request.dart';
import '../models/requests/update_supplement_category_request.dart';
import '../models/filters/supplement_category_query_filter.dart';

/// Supplement category service using generic CRUD pattern
class SupplementCategoryService extends CrudService<
    SupplementCategoryResponse,
    CreateSupplementCategoryRequest,
    UpdateSupplementCategoryRequest,
    SupplementCategoryQueryFilter> {
  SupplementCategoryService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/supplement-categories',
          responseParser: SupplementCategoryResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateSupplementCategoryRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateSupplementCategoryRequest request) =>
      request.toJson();
}
