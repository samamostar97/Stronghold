import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/staff_response.dart';

class StaffRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedStaffResponse> getStaff({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? staffType,
    bool orderDescending = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'orderDescending': orderDescending,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (staffType != null && staffType.isNotEmpty) params['staffType'] = staffType;

      final response = await _dio.get('/staff', queryParameters: params);
      return PagedStaffResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<StaffResponse> getStaffById(int id) async {
    try {
      final response = await _dio.get('/staff/$id');
      return StaffResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<StaffResponse> createStaff({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? bio,
    required String staffType,
  }) async {
    try {
      final response = await _dio.post('/staff', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'bio': bio,
        'staffType': staffType,
      });
      return StaffResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<StaffResponse> updateStaff({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? bio,
    required String staffType,
    required bool isActive,
  }) async {
    try {
      final response = await _dio.put('/staff/$id', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'bio': bio,
        'staffType': staffType,
        'isActive': isActive,
      });
      return StaffResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await _dio.delete('/staff/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
