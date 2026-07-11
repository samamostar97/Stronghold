import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiClient _api;

  OrdersProvider(this._api);

  List<Order> _orders = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 10;
  bool _loading = false;

  List<Order> get orders => _orders;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get loading => _loading;

  Future<void> load({int? page}) async {
    _page = page ?? _page;
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/orders/my', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Order.fromJson);
      _orders = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Checkout korak 1: server cita korpu iz baze, racuna iznos i vraca
  /// client secret za PaymentSheet - stavke se ne salju s klijenta.
  Future<Map<String, dynamic>> createPaymentIntent({
    required String deliveryStreet,
    required int deliveryCityId,
  }) async {
    return await _api.post('/api/orders/create-payment-intent', body: {
      'deliveryStreet': deliveryStreet,
      'deliveryCityId': deliveryCityId,
    }) as Map<String, dynamic>;
  }

  /// Checkout korak 3: server verifikuje placanje kod Stripe-a i kreira narudzbu.
  Future<Order> confirmOrder(String paymentIntentId) async {
    final data = await _api.post('/api/orders/confirm', body: {
      'paymentIntentId': paymentIntentId,
    }) as Map<String, dynamic>;
    await load(page: 1);
    return Order.fromJson(data);
  }
}
