import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/user.dart';
import '../utils/api_client.dart';

class UsersProvider extends ChangeNotifier {
  final ApiClient _api;

  UsersProvider(this._api);

  List<User> _users = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 10;
  String _searchText = '';
  bool _loading = false;

  List<User> get users => _users;
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
      final data = await _api.get('/api/users', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, User.fromJson);
      _users = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> insert(Map<String, dynamic> body) async {
    await _api.post('/api/users', body: body);
    await load(page: 1);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/api/users/$id', body: body);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/users/$id');
    await load();
  }

  /// URL slike korisnika - slika se servira preko zasebnog endpointa.
  Uri imageUri(int userId) => _api.buildUri('/api/users/$userId/image');

  Map<String, String> imageHeaders() => _api.authHeaders();
}
