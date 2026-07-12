import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/report_models.dart';
import '../utils/api_client.dart';

class ReportsProvider extends ChangeNotifier {
  final ApiClient _api;

  ReportsProvider(this._api);

  Dashboard? _dashboard;
  RevenueReport? _revenue;
  StaffReport? _staff;
  List<LeaderboardEntry> _leaderboard = [];

  // period izvjestaja - prvi dan mjeseca za "od" i "do"; default zadnjih 6 mjeseci
  DateTime _toMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime _fromMonth = DateTime(_toMonth.year, _toMonth.month - 5, 1);

  Dashboard? get dashboard => _dashboard;
  RevenueReport? get revenue => _revenue;
  StaffReport? get staff => _staff;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  DateTime get fromMonth => _fromMonth;
  DateTime get toMonth => _toMonth;

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

  static String _monthParam(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  Map<String, String> get _periodQuery => {
        'from': _monthParam(_fromMonth),
        'to': _monthParam(_toMonth),
      };

  /// Promjena perioda vazi za oba taba i za exporte.
  Future<void> setPeriod(DateTime from, DateTime to) async {
    _fromMonth = DateTime(from.year, from.month, 1);
    _toMonth = DateTime(to.year, to.month, 1);
    await loadReports();
  }

  Future<void> loadReports() async {
    // oba taba se ucitavaju paralelno, za isti period
    final results = await Future.wait([
      _api.get('/api/reports/revenue', query: _periodQuery),
      _api.get('/api/reports/staff', query: _periodQuery),
    ]);
    _revenue = RevenueReport.fromJson(results[0] as Map<String, dynamic>);
    _staff = StaffReport.fromJson(results[1] as Map<String, dynamic>);
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

  /// Preuzima PDF/Excel izvjestaj sa servera za odabrani period.
  Future<List<int>> downloadExport(String reportKey, String format) {
    final query = _periodQuery;
    return _api.getBytes(
        '/api/reports/$reportKey/$format?from=${query['from']}&to=${query['to']}');
  }
}
