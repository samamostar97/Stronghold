import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order_dto.dart';
import 'token_storage.dart';

class OrdersApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all orders with pagination and optional filters
  static Future<PagedOrdersResult> getOrders({
    String? search,
    OrderStatus? status,
    String? orderBy,
    bool descending = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status.index.toString(),
      if (orderBy != null && orderBy.isNotEmpty) 'orderBy': orderBy,
      if (descending) 'descending': 'true',
    };

    final uri = ApiConfig.uri('/api/admin/orders/GetAllPaged')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PagedOrdersResult.fromJson(json);
    }

    throw Exception('Failed to load orders: ${res.statusCode} ${res.body}');
  }

  /// Get a single order by ID with full details
  static Future<OrderDTO> getOrderById(int id) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/orders/$id'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return OrderDTO.fromJson(json);
    }

    throw Exception('Failed to load order: ${res.statusCode} ${res.body}');
  }

  /// Mark an order as delivered
  static Future<OrderDTO> markAsDelivered(int id) async {
    final res = await http.patch(
      ApiConfig.uri('/api/admin/orders/$id/deliver'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return OrderDTO.fromJson(json);
    }

    throw Exception('Failed to mark order as delivered: ${res.statusCode} ${res.body}');
  }
}
