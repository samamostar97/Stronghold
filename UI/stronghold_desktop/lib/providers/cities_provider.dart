import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class CitiesProvider extends ChangeNotifier {
  final ApiClient _api;

  CitiesProvider(this._api);

  List<City> _cities = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  String _searchName = '';
  bool _loading = false;

  List<City> get cities => _cities;
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
      final data = await _api.get('/api/cities', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchName.isNotEmpty) 'name': _searchName,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, City.fromJson);
      _cities = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Za dropdown-e na drugim formama - svi gradovi bez paginacije UI-ja.
  Future<List<City>> loadAll() async {
    final data = await _api.get('/api/cities', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, City.fromJson).items;
  }

  Future<void> insert(String name) async {
    await _api.post('/api/cities', body: {'name': name});
    await load(page: 1);
  }

  Future<void> update(int id, String name) async {
    await _api.put('/api/cities/$id', body: {'name': name});
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/cities/$id');
    await load();
  }
}
