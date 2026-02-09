import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/responses/order_response.dart';
import '../models/filters/order_query_filter.dart';

/// Order service for admin order management.
/// Orders are read-only from admin (no create/update) but can be marked as delivered.
class OrderService {
  final ApiClient _client;
  static const String _basePath = '/api/orders';

  OrderService(this._client);

  /// Get paginated list of orders with server-side filtering and sorting
  Future<PagedResult<OrderResponse>> getAll(OrderQueryFilter filter) async {
    return _client.get<PagedResult<OrderResponse>>(
      '$_basePath/GetAllPaged',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        OrderResponse.fromJson,
      ),
    );
  }

  /// Get single order by ID with full details
  Future<OrderResponse> getById(int id) async {
    return _client.get<OrderResponse>(
      '$_basePath/$id',
      parser: (json) => OrderResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Mark an order as delivered
  Future<OrderResponse> markAsDelivered(int id) async {
    return _client.patch<OrderResponse>(
      '$_basePath/$id/deliver',
      parser: (json) => OrderResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Cancel an order (admin only)
  Future<OrderResponse> cancelOrder(int id, {String? reason}) async {
    return _client.patch<OrderResponse>(
      '$_basePath/$id/cancel',
      body: reason != null ? {'reason': reason} : {},
      parser: (json) => OrderResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
