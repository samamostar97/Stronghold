import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recommendation.dart';
import 'token_storage.dart';

class RecommendationService {
  static Future<List<Recommendation>> getRecommendations({int count = 6}) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final uri = ApiConfig.uri('/api/user/recommendations').replace(
      queryParameters: {'count': count.toString()},
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja preporuka');
    }
  }
}
