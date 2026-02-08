import '../api/api_client.dart';
import '../models/responses/current_visitor_response.dart';
import '../models/requests/check_in_request.dart';

/// Visit service for gym check-in/check-out operations
class VisitService {
  final ApiClient _client;
  static const String _path = '/api/visits';

  VisitService(this._client);

  /// Get all current visitors (not checked out yet)
  Future<List<CurrentVisitorResponse>> getCurrentVisitors() async {
    return _client.get<List<CurrentVisitorResponse>>(
      '$_path/current-users-list',
      parser: (json) {
        // API returns either a direct list or a paged result with 'items'
        final List<dynamic> list;
        if (json is List) {
          list = json;
        } else if (json is Map<String, dynamic> && json.containsKey('items')) {
          list = json['items'] as List<dynamic>;
        } else {
          list = [];
        }
        return list
            .map((item) => CurrentVisitorResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Check in a user
  Future<CurrentVisitorResponse> checkIn(CheckInRequest request) async {
    return _client.post<CurrentVisitorResponse>(
      '$_path/check-in',
      body: request.toJson(),
      parser: (json) => CurrentVisitorResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Check out a visitor
  Future<void> checkOut(int visitId) async {
    await _client.post<void>(
      '$_path/check-out/$visitId',
      parser: (_) {},
    );
  }
}
