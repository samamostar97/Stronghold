import 'package:dio/dio.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && TokenStorage.refreshToken != null) {
      try {
        final response = await ApiClient.refreshInstance.post(
          '/auth/refresh-token',
          data: {'refreshToken': TokenStorage.refreshToken},
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        TokenStorage.accessToken = newAccessToken;
        TokenStorage.refreshToken = newRefreshToken;

        // Retry original request
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(options);
        return handler.resolve(retryResponse);
      } catch (_) {
        TokenStorage.clear();
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
}
