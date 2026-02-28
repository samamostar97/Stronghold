import 'package:stronghold_core/stronghold_core.dart';

/// User-facing seminar service (upcoming seminars for members)
class UserSeminarService {
  final ApiClient _client;

  UserSeminarService(this._client);

  /// Get upcoming seminars
  Future<List<UserSeminarResponse>> getUpcoming() async {
    return _client.get<List<UserSeminarResponse>>(
      '/api/seminars/upcoming',
      parser: (json) => (json as List<dynamic>)
          .map((j) =>
              UserSeminarResponse.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Attend a seminar
  Future<void> attend(int seminarId) async {
    await _client.post<void>(
      '/api/seminars/$seminarId/attend',
      parser: (_) {},
    );
  }

  /// Cancel seminar attendance
  Future<void> cancelAttendance(int seminarId) async {
    await _client.delete('/api/seminars/$seminarId/attend');
  }
}
