import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/report_models.dart';
import '../utils/api_client.dart';

class ReportsProvider extends ChangeNotifier {
  final ApiClient _api;

  ReportsProvider(this._api);

  Dashboard? _dashboard;
  RevenueReport? _revenue;
  InventoryReport? _inventory;
  MembershipReport? _memberships;
  List<LeaderboardEntry> _leaderboard = [];

  Dashboard? get dashboard => _dashboard;
  RevenueReport? get revenue => _revenue;
  InventoryReport? get inventory => _inventory;
  MembershipReport? get memberships => _memberships;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

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

  Future<void> loadReports() async {
    // tri taba se ucitavaju paralelno
    final results = await Future.wait([
      _api.get('/api/reports/revenue'),
      _api.get('/api/reports/inventory'),
      _api.get('/api/reports/memberships'),
    ]);
    _revenue = RevenueReport.fromJson(results[0] as Map<String, dynamic>);
    _inventory = InventoryReport.fromJson(results[1] as Map<String, dynamic>);
    _memberships = MembershipReport.fromJson(results[2] as Map<String, dynamic>);
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

  /// Preuzima PDF/Excel izvjestaj sa servera.
  Future<List<int>> downloadExport(String reportKey, String format) {
    return _api.getBytes('/api/reports/$reportKey/$format');
  }
}
