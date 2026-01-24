import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/membership_package_dto.dart';
import 'token_storage.dart';

class MembershipPackagesApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all membership packages with pagination and optional search filter
  static Future<PagedPackagesResult> getPackages({
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

    final uri = ApiConfig.uri('/api/admin/membership-package/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedPackagesResult.fromJson(json);
    }

    throw Exception('Failed to load packages: ${res.statusCode} ${res.body}');
  }

  /// Get a single package by ID
  static Future<MembershipPackageDTO> getPackageById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/membership-package/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return MembershipPackageDTO.fromJson(json);
    }

    throw Exception('Failed to load package: ${res.statusCode} ${res.body}');
  }

  /// Create a new membership package
  static Future<MembershipPackageDTO> createPackage(CreateMembershipPackageDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/membership-package'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return MembershipPackageDTO.fromJson(json);
    }

    throw Exception('Failed to create package: ${res.statusCode} ${res.body}');
  }

  /// Update an existing membership package
  static Future<MembershipPackageDTO> updatePackage(int id, UpdateMembershipPackageDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/membership-package/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return MembershipPackageDTO.fromJson(json);
    }

    if (res.statusCode == 204) {
      // No Content - fetch the updated package
      return getPackageById(id);
    }

    throw Exception('Failed to update package: ${res.statusCode} ${res.body}');
  }

  /// Delete a membership package
  static Future<void> deletePackage(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/membership-package/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete package: ${res.statusCode} ${res.body}');
    }
  }
}
