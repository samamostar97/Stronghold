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
      await TokenStorage.saveLogin(data);
      return data;
    }

    throw Exception('Login failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> logout() => TokenStorage.clear();
}
