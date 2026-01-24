import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/membership_dto.dart';
import '../models/membership_package_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class MembershipsApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<PagedMembershipPaymentsResult> getUserPayments(
    int userId, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    final uri = ApiConfig.uri('/api/admin/user/membership/$userId/history').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedMembershipPaymentsResult.fromJson(json, pageSize);
    }
    throw Exception(extractErrorMessage(res));
  }

  static Future<List<MembershipPackageDTO>> getPackages() async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/membership-package/GetAll'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as List<dynamic>;
      return json
          .map((e) => MembershipPackageDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(extractErrorMessage(res));
  }

  static Future<void> assignMembership(AddMembershipPaymentRequest request) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/user/membership'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }

  static Future<void> revokeMembership(int userId) async {
    final res = await http.patch(
      ApiConfig.uri('/api/admin/user/membership?id=$userId'),
      headers: await _headers(),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(extractErrorMessage(res));
    }
  }
}
