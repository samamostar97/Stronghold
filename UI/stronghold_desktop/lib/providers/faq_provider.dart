import 'package:flutter/foundation.dart';

import '../models/faq_item.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class FaqProvider extends ChangeNotifier {
  final ApiClient _api;

  FaqProvider(this._api);

  List<FaqItem> _items = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  String _searchText = '';
  bool _loading = false;

  List<FaqItem> get items => _items;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get loading => _loading;

  Future<void> load({int? page, String? searchText}) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/faqs', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, FaqItem.fromJson);
      _items = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/faqs', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/faqs/$id', body: body);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/faqs/$id');
    await load();
  }
}
