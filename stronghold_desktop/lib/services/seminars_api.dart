import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/seminar_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class SeminarsApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all seminars with pagination and optional search filter
  static Future<PagedSeminarsResult> getSeminars({
    String? search,
    String? orderBy,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (orderBy != null && orderBy.isNotEmpty) 'orderBy': orderBy,
    };

    final uri = ApiConfig.uri('/api/admin/seminar/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedSeminarsResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Get a single seminar by ID
  static Future<SeminarDTO> getSeminarById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/seminar/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return SeminarDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Create a new seminar
  static Future<int> createSeminar(CreateSeminarDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/seminar'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Update an existing seminar (partial update)
  static Future<void> updateSeminar(int id, UpdateSeminarDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/seminar/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  /// Soft delete a seminar
  static Future<void> deleteSeminar(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/seminar/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
