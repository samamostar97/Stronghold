import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stronghold_desktop/models/category_dto.dart';
import '../config/api_config.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class CategoriesApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all categories with pagination and optional search filter
  static Future<PagedCategoriesResult> getCategories({
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

    final uri = ApiConfig.uri('/api/admin/supplement-category/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedCategoriesResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Get a single category by ID
  static Future<CategoryDTO> getCategoryById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/supplement-category/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return CategoryDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Create a new supplement
  static Future<int> createCategory(CreateCategoryDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/supplement-category'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Update an existing supplement (partial update)
  static Future<void> updateCategory(int id, UpdateCategoryDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/supplement-category/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  /// Soft delete a supplement
  static Future<void> deleteCategory(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/supplement-category/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
