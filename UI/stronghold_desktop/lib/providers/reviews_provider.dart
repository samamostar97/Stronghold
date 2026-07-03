import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/review.dart';
import '../utils/api_client.dart';

class ReviewsProvider extends ChangeNotifier {
  final ApiClient _api;

  ReviewsProvider(this._api);

  List<Review> _reviews = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 12;
  String _searchText = '';
  bool _loading = false;

  List<Review> get reviews => _reviews;
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
      final data = await _api.get('/api/reviews', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Review.fromJson);
      _reviews = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
