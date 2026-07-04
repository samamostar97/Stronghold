import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class LeaderboardProvider extends ChangeNotifier {
  final ApiClient _api;

  LeaderboardProvider(this._api);

  List<LeaderboardEntry> _entries = [];
  bool _loading = false;

  List<LeaderboardEntry> get entries => _entries;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/leaderboard', query: {
        'page': '1',
        'pageSize': '50',
      }) as Map<String, dynamic>;
      _entries = PagedResult.fromJson(data, LeaderboardEntry.fromJson).items;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
