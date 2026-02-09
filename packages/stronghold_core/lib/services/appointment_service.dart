import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/filters/appointment_query_filter.dart';
import '../models/responses/admin_appointment_response.dart';

/// Appointment service for admin appointment listing.
/// Not a CrudService since appointments are read-only for admin.
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
}
