import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/supplier.dart';
import '../utils/api_client.dart';

class SuppliersProvider extends ChangeNotifier {
  final ApiClient _api;

  SuppliersProvider(this._api);

  List<Supplier> _suppliers = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  String _searchName = '';
  bool _loading = false;

  List<Supplier> get suppliers => _suppliers;
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
      final data = await _api.get('/api/suppliers', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchName.isNotEmpty) 'name': _searchName,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Supplier.fromJson);
      _suppliers = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Za dropdown na formi suplementa.
  Future<List<Supplier>> loadAll() async {
    final data = await _api.get('/api/suppliers', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, Supplier.fromJson).items;
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/suppliers', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/suppliers/$id', body: body);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/suppliers/$id');
    await load();
  }
}
