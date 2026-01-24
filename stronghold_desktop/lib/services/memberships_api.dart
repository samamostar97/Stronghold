import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/membership_dto.dart';
import '../models/membership_package_dto.dart';
import 'token_storage.dart';

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

    if (res.statusCode == 404) {
      throw Exception('Nije moguće učitati historiju uplata');
    }

    throw Exception('Greška pri učitavanju historije uplata');
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

    throw Exception('Nije moguće učitati pakete članarina');
  }

  static Future<void> assignMembership(AddMembershipPaymentRequest request) async {
    final res = await http.post(
      ApiConfig.uri('/api/admin/user/membership'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
      throw Exception('Nije moguće dodati članarinu');
    }
  }

  static Future<void> revokeMembership(int userId) async {
    final res = await http.patch(
      ApiConfig.uri('/api/admin/user/membership?id=$userId'),
      headers: await _headers(),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      // Try to parse error message from response body
      String errorMessage = 'Nije moguće ukinuti članarinu';

      try {
        if (res.body.isNotEmpty) {
          // Try to parse as JSON first
          final jsonResponse = jsonDecode(res.body);

          if (jsonResponse is Map) {
            // Check common error field names
            if (jsonResponse.containsKey('message')) {
              errorMessage = jsonResponse['message'];
            } else if (jsonResponse.containsKey('Message')) {
              errorMessage = jsonResponse['Message'];
            } else if (jsonResponse.containsKey('title')) {
              errorMessage = jsonResponse['title'];
            } else if (jsonResponse.containsKey('error')) {
              errorMessage = jsonResponse['error'];
            }
          } else if (jsonResponse is String) {
            errorMessage = jsonResponse;
          }
        }
      } catch (_) {
        // If JSON parsing fails, use the raw body if it's reasonable length
        if (res.body.isNotEmpty && res.body.length < 200) {
          errorMessage = res.body.replaceAll('"', '').trim();
        }
      }

      // Handle specific status codes with user-friendly messages
      if (res.statusCode == 404) {
        errorMessage = 'Korisnik nema aktivnu članarinu';
      } else if (res.statusCode == 400) {
        // Keep the error message from the backend if available
        if (errorMessage == 'Nije moguće ukinuti članarinu' && res.body.isNotEmpty) {
          errorMessage = res.body.replaceAll('"', '').trim();
        }
      }

      throw Exception(errorMessage);
    }
  }
}
