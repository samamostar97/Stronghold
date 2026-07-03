import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/payment.dart';
import '../utils/api_client.dart';

class PaymentsProvider extends ChangeNotifier {
  final ApiClient _api;

  PaymentsProvider(this._api);

  List<Payment> _payments = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  int? _userId;
  String _searchText = '';
  bool _loading = false;

  List<Payment> get payments => _payments;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get loading => _loading;

  Future<void> load({int? page, int? userId, String? searchText, bool clearUser = false}) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    if (clearUser) {
      _userId = null;
    } else {
      _userId = userId ?? _userId;
    }
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/payments', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_userId != null) 'userId': '$_userId',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Payment.fromJson);
      _payments = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Historija uplata jednog korisnika - za modal na ekranu clanarina.
  Future<List<Payment>> loadForUser(int userId) async {
    final data = await _api.get('/api/payments', query: {
      'page': '1',
      'pageSize': '50',
      'userId': '$userId',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, Payment.fromJson).items;
  }
}
