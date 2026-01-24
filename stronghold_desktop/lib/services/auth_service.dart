import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      // Check if user is Admin by decoding the JWT token
      final token = data['token'] as String?;
      if (token == null) {
        throw Exception('ACCESS_DENIED');
      }

      // Decode JWT payload (middle part)
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('ACCESS_DENIED');
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(payload) as Map<String, dynamic>;
      final role = claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();

      if (role != 'Admin') {
        throw Exception('ACCESS_DENIED');
      }

      await TokenStorage.saveLogin(data);
      return data;
    }

    throw Exception('Login failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> logout() => TokenStorage.clear();
}
