import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/filters/visit_query_filter.dart';
import '../models/responses/current_visitor_response.dart';
import '../models/requests/check_in_request.dart';

/// Visit service for gym check-in/check-out operations
class VisitService {
  final ApiClient _client;
  static const String _path = '/api/visits';

  VisitService(this._client);

  /// Get paged current visitors (not checked out yet)
  Future<PagedResult<CurrentVisitorResponse>> getCurrentVisitorsPaged(
    VisitQueryFilter filter,
  ) async {
    return _client.get<PagedResult<CurrentVisitorResponse>>(
      '$_path/current-users-list',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        CurrentVisitorResponse.fromJson,
      ),
    );
  }

  /// Get current visitors as a simple list (compatibility helper)
  Future<List<CurrentVisitorResponse>> getCurrentVisitors() async {
    final result = await getCurrentVisitorsPaged(
      VisitQueryFilter(pageNumber: 1, pageSize: 100, orderBy: 'checkindesc'),
    );
    return result.items;
  }

  /// Check in a user
  Future<CurrentVisitorResponse> checkIn(CheckInRequest request) async {
    return _client.post<CurrentVisitorResponse>(
      '$_path/check-in',
      body: request.toJson(),
      parser: (json) =>
          CurrentVisitorResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check out a visitor
  Future<void> checkOut(int visitId) async {
    await _client.post<void>('$_path/check-out/$visitId', parser: (_) {});
  }
}
