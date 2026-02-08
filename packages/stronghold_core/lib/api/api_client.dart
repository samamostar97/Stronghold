import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';
import '../storage/token_storage.dart';

/// Central HTTP client that handles authentication headers and error parsing.
/// Eliminates duplicate _headers() methods across service files.
class ApiClient {
  final http.Client _client;

  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  /// Builds authorization headers with JWT token
  Future<Map<String, String>> _headers({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.accessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// GET request with query parameters
  Future<T> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    var uri = ApiConfig.uri(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final response = await _client.get(
      uri,
      headers: await _headers(requiresAuth: requiresAuth),
    );
    return _handleResponse(response, parser);
  }

  /// POST request with JSON body
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    final response = await _client.post(
      ApiConfig.uri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, parser);
  }

  /// PUT request with JSON body
  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    final response = await _client.put(
      ApiConfig.uri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, parser);
  }

  /// PATCH request with JSON body
  Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    final response = await _client.patch(
      ApiConfig.uri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, parser);
  }

  /// DELETE request
  Future<void> delete(String path, {bool requiresAuth = true}) async {
    final response = await _client.delete(
      ApiConfig.uri(path),
      headers: await _headers(requiresAuth: requiresAuth),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  /// GET request that returns raw bytes (for file downloads)
  Future<List<int>> getBytes(
    String path, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    var uri = ApiConfig.uri(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final response = await _client.get(
      uri,
      headers: await _headers(requiresAuth: requiresAuth),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException.fromResponse(response.statusCode, response.body);
  }

  /// Multipart file upload
  Future<T> uploadFile<T>(
    String path,
    String filePath,
    String fieldName, {
    required T Function(dynamic json) parser,
  }) async {
    final token = await TokenStorage.accessToken();
    final request = http.MultipartRequest('POST', ApiConfig.uri(path));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, parser);
  }

  /// Handle response and parse JSON
  T _handleResponse<T>(http.Response response, T Function(dynamic json) parser) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return parser(null);
      }
      return parser(jsonDecode(response.body));
    }
    throw ApiException.fromResponse(response.statusCode, response.body);
  }

  void dispose() {
    _client.close();
  }
}
