import 'package:flutter/foundation.dart';

import '../models/gym_visit.dart';
import '../models/paged_result.dart';
import '../models/user.dart';
import '../utils/api_client.dart';

class VisitsProvider extends ChangeNotifier {
  final ApiClient _api;

  VisitsProvider(this._api);

  List<GymVisit> _currentVisits = [];
  List<GymVisit> _history = [];
  int _historyTotalCount = 0;
  int _historyPage = 1;
  final int _historyPageSize = 10;
  bool _loading = false;

  List<GymVisit> get currentVisits => _currentVisits;
  List<GymVisit> get history => _history;
  int get historyTotalCount => _historyTotalCount;
  int get historyPage => _historyPage;
  int get historyPageSize => _historyPageSize;
  bool get loading => _loading;

  Future<void> load({int? historyPage}) async {
    _historyPage = historyPage ?? _historyPage;
    _loading = true;
    notifyListeners();
    try {
      final current = await _api.get('/api/gym-visits', query: {
        'page': '1',
        'pageSize': '100',
        'onlyInGym': 'true',
      }) as Map<String, dynamic>;
      _currentVisits = PagedResult.fromJson(current, GymVisit.fromJson).items;

      final history = await _api.get('/api/gym-visits', query: {
        'page': '$_historyPage',
        'pageSize': '$_historyPageSize',
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(history, GymVisit.fromJson);
      _history = result.items;
      _historyTotalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clanovi sa aktivnom clanarinom koji nisu u teretani - za check-in modal.
  Future<List<User>> loadEligible(String searchText) async {
    final data = await _api.get('/api/gym-visits/eligible-users', query: {
      'page': '1',
      'pageSize': '50',
      if (searchText.isNotEmpty) 'text': searchText,
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, User.fromJson).items;
  }

  Future<void> checkIn(int userId) async {
    await _api.post('/api/gym-visits/check-in', body: {'userId': userId});
    await load();
  }

  Future<void> checkOut(int visitId) async {
    await _api.put('/api/gym-visits/$visitId/check-out');
    await load();
  }
}
