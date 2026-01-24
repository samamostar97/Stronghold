import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/faq_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class FaqApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<PagedFaqsResult> getFaqs({
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

    final uri = ApiConfig.uri('/api/admin/faq/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedFaqsResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }
    /// Get a single FAQ by ID
  static Future<FaqDTO> getFaqById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/faq/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return FaqDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Create a new FAQ
  static Future<int> createFaq(CreateFaqDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/faq'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Update an existing FAQ (partial update)
  static Future<void> updateFaq(int id, UpdateFaqDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/faq/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  /// Soft delete a FAQ
  static Future<void> deleteFaq(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/faq/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
