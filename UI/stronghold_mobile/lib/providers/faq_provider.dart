import 'package:flutter/foundation.dart';

import '../models/faq_item.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class FaqProvider extends ChangeNotifier {
  final ApiClient _api;

  FaqProvider(this._api);

  List<FaqItem> _items = [];
  bool _loading = false;

  List<FaqItem> get items => _items;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/faqs', query: {
        'page': '1',
        'pageSize': '100',
      }) as Map<String, dynamic>;
      _items = PagedResult.fromJson(data, FaqItem.fromJson).items;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
