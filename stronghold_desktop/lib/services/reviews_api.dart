import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stronghold_desktop/models/review_dto.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class ReviewsApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get reviews
static Future<PagedReviewsResult> getReviews({
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

    final uri = ApiConfig.uri('/api/admin/review/GetPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedReviewsResult.fromJson(json);
    }

    throw Exception('Failed to load reviews: ${res.statusCode} ${res.body}');
  }
  static Future<void> deleteReview(int id) async {
    final res = await http.delete(
      ApiConfig.uri('/api/admin/review/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete review: ${res.statusCode} ${res.body}');
    }
  }
}