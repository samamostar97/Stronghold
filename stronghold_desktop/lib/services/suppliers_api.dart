import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/supplier_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class SuppliersApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all suppliers with pagination and optional search filter
  static Future<PagedSuppliersResult> getSuppliers({
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

    final uri = ApiConfig.uri('/api/admin/supplier/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedSuppliersResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }
  /// Get a single supplier by ID
  static Future<SupplierDTO> getSupplierById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/supplier/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return SupplierDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Create a new supplement
  static Future<int> createSupplier(CreateSupplierDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/supplier'),
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
  static Future<void> updateSupplier(int id, UpdateSupplierDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/supplier/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  /// Soft delete a supplement
  static Future<void> deleteSupplier(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/supplier/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}


