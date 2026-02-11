import '../api/api_client.dart';
import '../storage/token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final client = ApiClient();
    try {
      final data = await client.post<Map<String, dynamic>>(
        '/api/auth/login/admin',
        body: {'username': username, 'password': password},
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );
      await TokenStorage.saveLogin(data);
      return data;
    } finally {
      client.dispose();
    }
  }

  static Future<void> logout() => TokenStorage.clear();
}
