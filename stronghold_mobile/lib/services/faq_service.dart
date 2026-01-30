import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/faq_models.dart';
import 'token_storage.dart';

class FaqService {
  static Future<List<Faq>> getFaqs() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/faq'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Faq.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja cestih pitanja');
    }
  }
}
