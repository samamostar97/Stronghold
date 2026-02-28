import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/seminar_response.dart';
import '../models/responses/seminar_attendee_response.dart';
import '../models/requests/create_seminar_request.dart';
import '../models/requests/update_seminar_request.dart';
import '../models/filters/seminar_query_filter.dart';

class SeminarService {
  final ApiClient _client;
  static const String _path = '/api/seminars';

  SeminarService(this._client);

  Future<PagedResult<SeminarResponse>> getAll(SeminarQueryFilter filter) {
    return _client.get<PagedResult<SeminarResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, SeminarResponse.fromJson),
    );
  }

  Future<List<SeminarResponse>> getAllUnpaged(SeminarQueryFilter filter) {
    return _client.get<List<SeminarResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => SeminarResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<SeminarResponse> getById(int id) {
    return _client.get<SeminarResponse>(
      '$_path/$id',
      parser: (json) => SeminarResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateSeminarRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateSeminarRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');

  Future<List<SeminarAttendeeResponse>> getAttendees(int seminarId) {
    return _client.get<List<SeminarAttendeeResponse>>(
      '$_path/$seminarId/attendees',
      parser: (json) => (json as List).map((e) => SeminarAttendeeResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> cancelSeminar(int seminarId) {
    return _client.patch<void>(
      '$_path/$seminarId/cancel',
      parser: (_) {},
    );
  }
}
