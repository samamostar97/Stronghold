import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/supplement_category.dart';
import '../utils/api_client.dart';

class CategoriesProvider extends ChangeNotifier {
  final ApiClient _api;

  CategoriesProvider(this._api);

  List<SupplementCategory> _categories = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  String _searchName = '';
  bool _loading = false;

  List<SupplementCategory> get categories => _categories;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get loading => _loading;

  Future<void> load({int? page, String? searchName}) async {
    _page = page ?? _page;
    _searchName = searchName ?? _searchName;
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/supplement-categories', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchName.isNotEmpty) 'name': _searchName,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, SupplementCategory.fromJson);
      _categories = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Za dropdown na formi suplementa.
  Future<List<SupplementCategory>> loadAll() async {
    final data = await _api.get('/api/supplement-categories', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, SupplementCategory.fromJson).items;
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/supplement-categories', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/supplement-categories/$id', body: body);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/supplement-categories/$id');
    await load();
  }
}
