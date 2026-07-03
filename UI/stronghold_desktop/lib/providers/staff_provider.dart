import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/staff_member.dart';
import '../utils/api_client.dart';

class StaffProvider extends ChangeNotifier {
  final ApiClient _api;

  StaffProvider(this._api);

  List<StaffMember> _staff = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 10;
  String _searchText = '';
  bool _loading = false;

  List<StaffMember> get staff => _staff;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  bool get loading => _loading;

  /// staffType: 0 = Trainer, 1 = Nutritionist (UI prikazuje dva odvojena ekrana).
  Future<void> load(int staffType, {int? page, String? searchText}) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/staff-members', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        'staffType': '$staffType',
        if (_searchText.isNotEmpty) 'text': _searchText,
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, StaffMember.fromJson);
      _staff = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Svo osoblje - za dropdown pri dodavanju termina.
  Future<List<StaffMember>> loadAll() async {
    final data = await _api.get('/api/staff-members', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, StaffMember.fromJson).items;
  }

  Future<void> insert(int staffType, Map<String, dynamic> body) async {
    await _api.post('/api/staff-members', body: body);
    await load(staffType, page: 1);
  }

  Future<void> update(int staffType, int id, Map<String, dynamic> body) async {
    await _api.put('/api/staff-members/$id', body: body);
    await load(staffType);
  }

  Future<void> delete(int staffType, int id) async {
    await _api.delete('/api/staff-members/$id');
    await load(staffType);
  }

  Uri imageUri(int staffId) => _api.buildUri('/api/staff-members/$staffId/image');

  Map<String, String> imageHeaders() => _api.authHeaders();
}
