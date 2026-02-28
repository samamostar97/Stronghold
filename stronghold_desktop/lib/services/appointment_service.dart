import 'package:stronghold_core/stronghold_core.dart';

/// Appointment service for admin appointment management.
class AppointmentService {
  final ApiClient _client;
  static const _basePath = '/api/appointments';

  AppointmentService(this._client);

  /// Get all appointments (admin only) with pagination, search, sorting
  Future<PagedResult<AdminAppointmentResponse>> getAll(
      AppointmentQueryFilter filter) async {
    return _client.get<PagedResult<AdminAppointmentResponse>>(
      '$_basePath/admin',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        AdminAppointmentResponse.fromJson,
      ),
    );
  }

  /// Create a new appointment (admin only)
  Future<int> adminCreate(AdminCreateAppointmentRequest request) async {
    final result = await _client.post<Map<String, dynamic>>(
      '$_basePath/admin',
      body: request.toJson(),
      parser: (json) => json as Map<String, dynamic>,
    );
    return result['id'] as int;
  }

  /// Update an existing appointment (admin only)
  Future<void> adminUpdate(
      int id, AdminUpdateAppointmentRequest request) async {
    await _client.put<void>(
      '$_basePath/admin/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  /// Delete an appointment (admin only)
  Future<void> adminDelete(int id) async {
    await _client.delete('$_basePath/admin/$id');
  }
}
