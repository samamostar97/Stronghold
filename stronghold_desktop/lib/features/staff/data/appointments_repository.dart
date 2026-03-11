import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/appointment_response.dart';

class AppointmentsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedAppointmentResponse> getAppointments({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? status,
    int? staffId,
    String? orderBy,
    bool orderDescending = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'orderDescending': orderDescending,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (staffId != null) params['staffId'] = staffId;
      if (orderBy != null) params['orderBy'] = orderBy;

      final response = await _dio.get('/appointments', queryParameters: params);
      return PagedAppointmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppointmentResponse> approveAppointment(int id) async {
    try {
      final response = await _dio.put('/appointments/$id/approve');
      return AppointmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppointmentResponse> rejectAppointment(int id) async {
    try {
      final response = await _dio.put('/appointments/$id/reject');
      return AppointmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppointmentResponse> completeAppointment(int id) async {
    try {
      final response = await _dio.put('/appointments/$id/complete');
      return AppointmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required int staffId,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/staff/$staffId/available-slots',
        queryParameters: {'date': date},
      );
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppointmentResponse> adminCreateAppointment({
    required int userId,
    required int staffId,
    required String scheduledAt,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/admin/appointments', data: {
        'userId': userId,
        'staffId': staffId,
        'scheduledAt': scheduledAt,
        'notes': notes,
      });
      return AppointmentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
