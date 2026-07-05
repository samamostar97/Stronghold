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
  final int _pageSize = 12;
  String _searchText = '';
  String? _status;
  bool _loading = false;

  List<Order> get orders => _orders;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  String? get status => _status;
  bool get loading => _loading;

  Future<void> load({
    int? page,
    String? searchText,
    String? status,
    bool clearStatus = false,
  }) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    _status = clearStatus ? null : (status ?? _status);
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/orders', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
        'status': ?_status,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Order.fromJson);
      _orders = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deliver(int id) async {
    await _api.put('/api/orders/$id/deliver');
    await load();
  }

  /// Otkazivanje placene narudzbe pokrece stvarni Stripe refund.
  Future<void> cancel(int id, String reason) async {
    await _api.put('/api/orders/$id/cancel', body: {'reason': reason});
    await load();
  }
}
