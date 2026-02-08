import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';
import '../storage/token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Auth/login/admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await TokenStorage.saveLogin(data);
      return data;
    }

    if (res.statusCode == 403) {
      throw Exception('ACCESS_DENIED');
    }

    if (res.statusCode == 401) {
      throw Exception('INVALID_CREDENTIALS');
    }

    throw Exception('Login failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> logout() => TokenStorage.clear();
}
