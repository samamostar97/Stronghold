import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/supplement_category_dto.dart';
import 'token_storage.dart';

class SupplementCategoriesApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all supplement categories
  static Future<List<SupplementCategoryDTO>> getCategories() async {
    final queryParams = <String, String>{
      'pageNumber': '1',
      'pageSize': '1000',
    };

    final uri = ApiConfig.uri('/api/admin/supplement-categories/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final itemsList = (json['items'] as List<dynamic>?)
              ?.map((e) => SupplementCategoryDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <SupplementCategoryDTO>[];
      return itemsList;
    }

    throw Exception('Failed to load categories: ${res.statusCode} ${res.body}');
  }
}
