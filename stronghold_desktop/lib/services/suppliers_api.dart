import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/supplier_dto.dart';
import 'token_storage.dart';

class SuppliersApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all supplements with optional search filter
  static Future<List<SupplierDTO>> getSuppliers({String? search}) async {
    final queryParams = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = ApiConfig.uri('/api/admin/suppliers')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final jsonList = jsonDecode(res.body) as List<dynamic>;
      return jsonList
          .map((e) => SupplierDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load suppliers: ${res.statusCode} ${res.body}');
  }

  /// Get a single category by ID
  static Future<SupplierDTO> geSupplierById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/suppliers/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return SupplierDTO.fromJson(json);
    }

    throw Exception('Failed to load suppliers: ${res.statusCode} ${res.body}');
  }

  /// Create a new supplement
  static Future<int> createSupplier(CreateSupplierDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/suppliers'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception('Failed to create supplier: ${res.statusCode} ${res.body}');
  }

  /// Update an existing supplement (partial update)
  static Future<void> updateSupplier(int id, UpdateSupplierDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/suppliers/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to update supplier: ${res.statusCode} ${res.body}');
    }
  }

  /// Soft delete a supplement
  static Future<void> deleteSupplier(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/suppliers/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete supplier: ${res.statusCode} ${res.body}');
    }
  }
}
