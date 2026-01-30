import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/cart_models.dart';
import '../models/checkout_models.dart';
import 'token_storage.dart';

class CheckoutService {
  static Future<CheckoutResponse> createPaymentIntent(List<CartItem> items) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final body = jsonEncode({
      'items': items.map((item) {
        return {
          'supplementId': item.supplement.id,
          'quantity': item.quantity,
        };
      }).toList(),
    });

    final response = await http.post(
      ApiConfig.uri('/api/user/checkout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CheckoutResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['error'] ?? 'Greska prilikom kreiranja placanja';
        throw Exception(message);
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) rethrow;
        throw Exception('Greska prilikom kreiranja placanja');
      }
    }
  }

  static Future<void> confirmOrder(String paymentIntentId, List<CartItem> items) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final body = jsonEncode({
      'paymentIntentId': paymentIntentId,
      'items': items.map((item) {
        return {
          'supplementId': item.supplement.id,
          'quantity': item.quantity,
        };
      }).toList(),
    });

    final response = await http.post(
      ApiConfig.uri('/api/user/checkout/confirm'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['error'] ?? 'Greska prilikom potvrde narudzbe';
        throw Exception(message);
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) rethrow;
        throw Exception('Greska prilikom potvrde narudzbe');
      }
    }
  }
}
