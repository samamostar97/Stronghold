import 'package:stronghold_core/stronghold_core.dart';

/// User-facing order service (member's own orders + checkout)
class UserOrderService {
  final ApiClient _client;

  UserOrderService(this._client);

  /// Get current user's orders (paginated)
  Future<PagedResult<UserOrderResponse>> getMyOrders({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _client.get<PagedResult<UserOrderResponse>>(
      '/api/orders/my',
      queryParameters: {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      },
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        UserOrderResponse.fromJson,
      ),
    );
  }

  /// Create a Stripe payment intent for checkout
  Future<CheckoutResponse> checkout(
      List<Map<String, dynamic>> items) async {
    return _client.post<CheckoutResponse>(
      '/api/orders/checkout',
      body: {'items': items},
      parser: (json) =>
          CheckoutResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Confirm order after successful Stripe payment
  Future<void> confirmOrder(
      String paymentIntentId, List<Map<String, dynamic>> items) async {
    await _client.post<void>(
      '/api/orders/checkout/confirm',
      body: {
        'paymentIntentId': paymentIntentId,
        'items': items,
      },
      parser: (_) {},
    );
  }
}
