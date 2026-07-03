import 'package:flutter/foundation.dart';

import '../models/membership_package.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class PackagesProvider extends ChangeNotifier {
  final ApiClient _api;

  PackagesProvider(this._api);

  List<MembershipPackage> _packages = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 15;
  String _searchName = '';
  bool _loading = false;

  List<MembershipPackage> get packages => _packages;
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
      final data = await _api.get('/api/membership-packages', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchName.isNotEmpty) 'name': _searchName,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, MembershipPackage.fromJson);
      _packages = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Za dropdown pri dodjeli clanarine.
  Future<List<MembershipPackage>> loadAll() async {
    final data = await _api.get('/api/membership-packages', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, MembershipPackage.fromJson).items;
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/membership-packages', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/membership-packages/$id', body: body);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/membership-packages/$id');
    await load();
  }
}
