import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/supplement_response.dart';
import '../models/requests/create_supplement_request.dart';
import '../models/requests/update_supplement_request.dart';
import '../models/filters/supplement_query_filter.dart';
import '../models/responses/supplement_review_response.dart';

/// Supplement service using new generic CRUD pattern
/// Old: 100+ LOC in supplements_api.dart with duplicate _headers()
/// New: ~20 LOC, no duplication
class SupplementService extends CrudServiceWithImage<
    SupplementResponse,
    CreateSupplementRequest,
    UpdateSupplementRequest,
    SupplementQueryFilter> {
  final ApiClient _apiClient;

  SupplementService(ApiClient client)
      : _apiClient = client,
        super(
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

  /// Get reviews for a specific supplement
  Future<List<SupplementReviewResponse>> getReviews(int supplementId) async {
    return _apiClient.get<List<SupplementReviewResponse>>(
      '/api/supplements/$supplementId/reviews',
      parser: (json) => (json as List<dynamic>)
          .map((j) =>
              SupplementReviewResponse.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }
}
