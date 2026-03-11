import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiClient.refreshInstance.post(
        '/admin/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      TokenStorage.save(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );

      return data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout', data: {
        'refreshToken': TokenStorage.refreshToken,
      });
    } catch (_) {
      // Silently ignore
    } finally {
      TokenStorage.clear();
      ApiClient.reset();
    }
  }
}
