import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class UsersApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<PagedUsersResult> getUsers({
    String? search,
    String? orderBy,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'name': search,
      if (orderBy != null && orderBy.isNotEmpty) 'orderBy': orderBy,
    };

    final uri = ApiConfig.uri('/api/admin/user/GetAllPaged').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedUsersResult.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  static Future<UserDetailsDTO> getUserById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/user/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return UserDetailsDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  static Future<int> createUser(CreateUserDTO dto) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/user'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['id'] as int;
    }

    throw Exception(extractErrorMessage(res));
  }

  static Future<void> updateUser(int id, UpdateUserDTO dto) async {
    final res = await http.put(
      ApiConfig.uri('/api/admin/user/$id'),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(extractErrorMessage(res));
    }
  }

  static Future<void> deleteUser(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/user/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(extractErrorMessage(res));
    }
  }

  static Future<void> restoreUser(int id) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/user/$id/restore'),
      headers: await _headers(),
    );

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
