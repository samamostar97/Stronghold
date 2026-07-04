import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/supplement.dart';
import '../utils/api_client.dart';

class ShopProvider extends ChangeNotifier {
  final ApiClient _api;

  ShopProvider(this._api);

  List<Supplement> _supplements = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 20;
  String _searchText = '';
  int? _categoryId;
  bool _loading = false;

  List<Supplement> get supplements => _supplements;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  int? get categoryId => _categoryId;
  bool get loading => _loading;

  Future<void> load({int? page, String? searchText, int? categoryId, bool clearCategory = false}) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    if (clearCategory) {
      _categoryId = null;
    } else {
      _categoryId = categoryId ?? _categoryId;
    }
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/supplements', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
        if (_categoryId != null) 'categoryId': '$_categoryId',
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Supplement.fromJson);
      _supplements = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// URL slike suplementa - slika se servira preko zasebnog endpointa.
  Uri imageUri(int supplementId) => _api.buildUri('/api/supplements/$supplementId/image');

  Map<String, String> imageHeaders() => _api.authHeaders();
}
