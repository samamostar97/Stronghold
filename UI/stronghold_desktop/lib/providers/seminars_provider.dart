import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/seminar.dart';
import '../utils/api_client.dart';

class SeminarsProvider extends ChangeNotifier {
  final ApiClient _api;

  SeminarsProvider(this._api);

  List<Seminar> _seminars = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 12;
  String _searchText = '';
  bool _loading = false;

  List<Seminar> get seminars => _seminars;
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
      final data = await _api.get('/api/seminars', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Seminar.fromJson);
      _seminars = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<SeminarRegistration>> loadRegistrations(int seminarId) async {
    final data = await _api.get('/api/seminars/$seminarId/registrations') as List;
    return data
        .map((item) => SeminarRegistration.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/seminars', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/seminars/$id', body: body);
    await load();
  }

  /// Otkaz seminara - svi prijavljeni dobijaju notifikaciju i e-mail.
  Future<void> cancel(int id, String reason) async {
    await _api.put('/api/seminars/$id/cancel', body: {'reason': reason});
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/seminars/$id');
    await load();
  }
}
