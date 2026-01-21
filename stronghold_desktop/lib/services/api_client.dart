import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';


class ApiClient {
  static Future<http.Response> get(String path) async {
    final token = await TokenStorage.accessToken();
    return http.get(
      ApiConfig.uri(path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await TokenStorage.accessToken();
    return http.post(
      ApiConfig.uri(path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}
