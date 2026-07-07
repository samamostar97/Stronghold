import 'package:flutter/foundation.dart';

import '../models/membership.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class MembershipsProvider extends ChangeNotifier {
  final ApiClient _api;

  MembershipsProvider(this._api);

  List<Membership> _memberships = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 12;
  String _searchText = '';
  bool _onlyActive = false;
  bool _loading = false;

  List<Membership> get memberships => _memberships;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get onlyActive => _onlyActive;
  bool get loading => _loading;

  Future<void> load({int? page, String? searchText, bool? onlyActive}) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    _onlyActive = onlyActive ?? _onlyActive;
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/memberships', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
        if (_onlyActive) 'onlyActive': 'true',
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Membership.fromJson);
      _memberships = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Aktivna clanarina clana - za upozorenje u dijalogu nove uplate.
  Future<ActiveMembershipInfo> activeForUser(int userId) async {
    final data = await _api.get('/api/memberships/user/$userId/active')
        as Map<String, dynamic>;
    return ActiveMembershipInfo.fromJson(data);
  }

  /// Dodjela clanarine = evidencija uplate; aktivira ili produzava clanarinu.
  Future<void> assign({required int userId, required int packageId}) async {
    await _api.post('/api/memberships', body: {
      'userId': userId,
      'packageId': packageId,
    });
    await load(page: 1);
  }

  Future<void> revoke(int id, String reason) async {
    await _api.put('/api/memberships/$id/revoke', body: {'reason': reason});
    await load();
  }
}
