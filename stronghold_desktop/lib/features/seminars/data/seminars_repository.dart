import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/seminar_response.dart';

class SeminarsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedSeminarResponse> getSeminars({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? status,
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

      final response = await _dio.get('/seminars', queryParameters: params);
      return PagedSeminarResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SeminarResponse> createSeminar({
    required String name,
    required String description,
    required String lecturer,
    required DateTime startDate,
    required int maxCapacity,
  }) async {
    try {
      final response = await _dio.post('/seminars', data: {
        'name': name,
        'description': description,
        'lecturer': lecturer,
        'startDate': startDate.toIso8601String(),
        'maxCapacity': maxCapacity,
      });
      return SeminarResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SeminarResponse> updateSeminar({
    required int id,
    required String name,
    required String description,
    required String lecturer,
    required DateTime startDate,
    required int maxCapacity,
  }) async {
    try {
      final response = await _dio.put('/seminars/$id', data: {
        'name': name,
        'description': description,
        'lecturer': lecturer,
        'startDate': startDate.toIso8601String(),
        'maxCapacity': maxCapacity,
      });
      return SeminarResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteSeminar(int id) async {
    try {
      await _dio.delete('/seminars/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<SeminarRegistrationResponse>> getRegistrations(int id) async {
    try {
      final response = await _dio.get('/seminars/$id/registrations');
      return (response.data as List)
          .map((e) =>
              SeminarRegistrationResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
