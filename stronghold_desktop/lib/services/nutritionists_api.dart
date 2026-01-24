import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/nutritionist_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class NutritionistsApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all nutritionists with pagination and optional search filter
  static Future<PagedNutritionistsResult> getNutritionists({
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

    final uri = ApiConfig.uri('/api/admin/nutritionist/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedNutritionistsResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Get a single nutritionist by ID
  static Future<NutritionistDTO> getNutritionistById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/nutritionist/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return NutritionistDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Create a new nutritionist
  static Future<int> createNutritionist(CreateNutritionistDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/nutritionist'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Update an existing nutritionist (partial update)
  static Future<void> updateNutritionist(int id, UpdateNutritionistDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/nutritionist/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  /// Delete a nutritionist
  static Future<void> deleteNutritionist(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/nutritionist/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
