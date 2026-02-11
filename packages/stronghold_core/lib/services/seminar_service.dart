import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/seminar_response.dart';
import '../models/responses/seminar_attendee_response.dart';
import '../models/requests/create_seminar_request.dart';
import '../models/requests/update_seminar_request.dart';
import '../models/filters/seminar_query_filter.dart';

/// Seminar service using generic CRUD pattern
class SeminarService
    extends
        CrudService<
          SeminarResponse,
          CreateSeminarRequest,
          UpdateSeminarRequest,
          SeminarQueryFilter
        > {
  final ApiClient _apiClient;

  SeminarService(ApiClient client)
    : _apiClient = client,
      super(
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

  /// Get attendees for a specific seminar (admin only)
  Future<List<SeminarAttendeeResponse>> getAttendees(int seminarId) async {
    return _apiClient.get<List<SeminarAttendeeResponse>>(
      '/api/seminar/$seminarId/attendees',
      parser: (json) => (json as List<dynamic>)
          .map(
            (e) => SeminarAttendeeResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Cancel a seminar (admin only)
  Future<void> cancelSeminar(int seminarId) async {
    await _apiClient.patch<void>(
      '/api/seminar/$seminarId/cancel',
      parser: (_) {},
    );
  }
}
