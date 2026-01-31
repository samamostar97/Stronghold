import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/review_models.dart';
import 'token_storage.dart';

class ReviewService {
  static Future<List<Review>> getReviewHistory() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/review'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja historije recenzija');
    }
  }

  static Future<List<PurchasedSupplement>> getAvailableSupplements() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/review/available-supplements'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) =>
              PurchasedSupplement.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja suplemenata');
    }
  }

  static Future<void> createReview(
      int supplementId, int rating, String? comment) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.post(
      ApiConfig.uri('/api/user/review'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'supplementId': supplementId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      final body = jsonDecode(response.body);
      final message = body is Map && body.containsKey('message')
          ? body['message']
          : 'Greska prilikom kreiranja recenzije';
      throw Exception(message);
    }
  }

  static Future<void> deleteReview(int reviewId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.delete(
      ApiConfig.uri('/api/user/review/$reviewId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else if (response.statusCode == 404) {
      throw Exception('Recenzija nije pronadena');
    } else {
      throw Exception('Greska prilikom brisanja recenzije');
    }
  }
}
