import 'package:stronghold_core/stronghold_core.dart';

/// User-facing appointment service (member's own appointments)
class UserAppointmentService {
  final ApiClient _client;

  UserAppointmentService(this._client);

  /// Get current user's appointments (paginated)
  Future<PagedResult<UserAppointmentResponse>> getMyAppointments({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _client.get<PagedResult<UserAppointmentResponse>>(
      '/api/appointments/my',
      queryParameters: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        UserAppointmentResponse.fromJson,
      ),
    );
  }

  /// Cancel an appointment
  Future<void> cancel(int id) async {
    await _client.delete('/api/appointments/$id');
  }

  /// Book a trainer appointment
  Future<void> bookTrainer(int trainerId, DateTime date) async {
    await _client.post<void>(
      '/api/trainers/$trainerId/appointments',
      body: {'date': DateTimeUtils.toApiDateTime(date)},
      parser: (_) {},
    );
  }

  /// Book a nutritionist appointment
  Future<void> bookNutritionist(int nutritionistId, DateTime date) async {
    await _client.post<void>(
      '/api/nutritionists/$nutritionistId/appointments',
      body: {'date': DateTimeUtils.toApiDateTime(date)},
      parser: (_) {},
    );
  }
}
