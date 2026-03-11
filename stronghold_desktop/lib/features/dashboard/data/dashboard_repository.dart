import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class DashboardRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getActivity({int count = 15}) async {
    try {
      final response = await _dio.get('/dashboard/activity', queryParameters: {
        'count': count,
      });
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
