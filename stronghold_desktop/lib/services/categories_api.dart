import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stronghold_desktop/models/category_dto.dart';
import '../config/api_config.dart';
import '../models/supplement_dto.dart';
import 'token_storage.dart';

class CategoriesApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all supplements with optional search filter
  static Future<List<CategoryDTO>> getCategories({String? search}) async {
    final queryParams = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = ApiConfig.uri('/api/admin/categories')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final jsonList = jsonDecode(res.body) as List<dynamic>;
      return jsonList
          .map((e) => CategoryDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load categories: ${res.statusCode} ${res.body}');
  }

  /// Get a single category by ID
  static Future<CategoryDTO> getCategoryById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/categories/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return CategoryDTO.fromJson(json);
    }

    throw Exception('Failed to load categories: ${res.statusCode} ${res.body}');
  }

  /// Create a new supplement
  static Future<int> createCategory(CreateCategoryDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/categories'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception('Failed to create category: ${res.statusCode} ${res.body}');
  }

  /// Update an existing supplement (partial update)
  static Future<void> updateCategory(int id, UpdateCategoryDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/categories/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to update category: ${res.statusCode} ${res.body}');
    }
  }

  /// Soft delete a supplement
  static Future<void> deleteCategory(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/categories/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete category: ${res.statusCode} ${res.body}');
    }
  }
}
