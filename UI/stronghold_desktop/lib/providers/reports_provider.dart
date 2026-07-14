import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/report_models.dart';
import '../utils/api_client.dart';

class ReportsProvider extends ChangeNotifier {
  final ApiClient _api;

  ReportsProvider(this._api);

  Dashboard? _dashboard;
  MembershipsReport? _memberships;
  ShopReport? _shop;
  List<LeaderboardEntry> _leaderboard = [];

  // period izvjestaja na nivou dana; default zadnjih 30 dana, opcioni filter po clanu
  DateTime _toDate = DateTime.now();
  late DateTime _fromDate = _toDate.subtract(const Duration(days: 29));
  int? _memberUserId;

  Dashboard? get dashboard => _dashboard;
  MembershipsReport? get memberships => _memberships;
  ShopReport? get shop => _shop;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  int? get memberUserId => _memberUserId;

  List<ActivityLogEntry> _activities = [];

  List<ActivityLogEntry> get activities => _activities;

  Future<void> loadDashboard() async {
    // dashboard i nedavne aktivnosti se ucitavaju paralelno
    final results = await Future.wait([
      _api.get('/api/reports/dashboard'),
      _api.get('/api/activity-logs', query: {'page': '1', 'pageSize': '8'}),
    ]);
    _dashboard = Dashboard.fromJson(results[0] as Map<String, dynamic>);
    _activities = PagedResult.fromJson(
      results[1] as Map<String, dynamic>,
      ActivityLogEntry.fromJson,
    ).items;
    notifyListeners();
  }

  /// Undo akcije u roku 1h - backend validira rok i vrstu zapisa.
  Future<void> undoActivity(int id) async {
    await _api.post('/api/activity-logs/$id/undo');
    await loadDashboard();
  }

  static String _dayParam(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  Map<String, String> get _reportQuery => {
        'from': _dayParam(_fromDate),
        'to': _dayParam(_toDate),
        if (_memberUserId != null) 'userId': '$_memberUserId',
      };

  /// Promjena filtera (period i/ili clan) vazi za oba taba i za exporte.
  Future<void> setFilters({
    DateTime? from,
    DateTime? to,
    int? userId,
    bool clearUser = false,
  }) async {
    if (from != null) _fromDate = from;
    if (to != null) _toDate = to;
    if (userId != null || clearUser) _memberUserId = userId;
    await loadReports();
  }

  Future<void> loadReports() async {
    // oba taba se ucitavaju paralelno, za iste filtere
    final results = await Future.wait([
      _api.get('/api/reports/memberships', query: _reportQuery),
      _api.get('/api/reports/shop', query: _reportQuery),
    ]);
    _memberships =
        MembershipsReport.fromJson(results[0] as Map<String, dynamic>);
    _shop = ShopReport.fromJson(results[1] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> loadLeaderboard() async {
    final data = await _api.get('/api/leaderboard', query: {
      'page': '1',
      'pageSize': '50',
    }) as Map<String, dynamic>;
    _leaderboard = PagedResult.fromJson(data, LeaderboardEntry.fromJson).items;
    notifyListeners();
  }

  /// Preuzima PDF/Excel izvjestaj sa servera za odabrane filtere.
  Future<List<int>> downloadExport(String reportKey, String format) {
    final query = _reportQuery;
    final user = query.containsKey('userId') ? '&userId=${query['userId']}' : '';
    return _api.getBytes(
        '/api/reports/$reportKey/$format?from=${query['from']}&to=${query['to']}$user');
  }
}
