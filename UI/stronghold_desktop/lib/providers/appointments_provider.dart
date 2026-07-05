import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

class AppointmentsProvider extends ChangeNotifier {
  final ApiClient _api;

  AppointmentsProvider(this._api);

  List<Appointment> _appointments = [];
  int _totalCount = 0;
  int _page = 1;
  final int _pageSize = 12;
  String _searchText = '';
  String? _status;
  DateTime? _date;
  bool _loading = false;

  List<Appointment> get appointments => _appointments;
  int get totalCount => _totalCount;
  int get page => _page;
  int get pageSize => _pageSize;
  String? get status => _status;
  DateTime? get date => _date;
  bool get loading => _loading;

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> load({
    int? page,
    String? searchText,
    String? status,
    bool clearStatus = false,
    DateTime? date,
    bool clearDate = false,
  }) async {
    _page = page ?? _page;
    _searchText = searchText ?? _searchText;
    _status = clearStatus ? null : (status ?? _status);
    _date = clearDate ? null : (date ?? _date);
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/appointments', query: {
        'page': '$_page',
        'pageSize': '$_pageSize',
        if (_searchText.isNotEmpty) 'text': _searchText,
        'status': ?_status,
        if (_date != null) 'date': _formatDate(_date!),
      }) as Map<String, dynamic>;
      final result = PagedResult.fromJson(data, Appointment.fromJson);
      _appointments = result.items;
      _totalCount = result.totalCount;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<int>> loadFreeSlots(int staffMemberId, DateTime date) async {
    final data = await _api.get('/api/appointments/free-slots', query: {
      'staffMemberId': '$staffMemberId',
      'date': _formatDate(date),
    }) as List;
    return data.cast<int>();
  }

  /// Admin direktno dodaje termin za odabranog clana.
  Future<void> create({
    required int userId,
    required int staffMemberId,
    required DateTime date,
    required int startHour,
  }) async {
    await _api.post('/api/appointments', body: {
      'userId': userId,
      'staffMemberId': staffMemberId,
      'date': _formatDate(date),
      'startHour': startHour,
    });
    await load(page: 1);
  }

  Future<void> confirm(int id) async {
    await _api.put('/api/appointments/$id/confirm');
    await load();
  }

  Future<void> complete(int id) async {
    await _api.put('/api/appointments/$id/complete');
    await load();
  }

  Future<void> cancel(int id, String reason) async {
    await _api.put('/api/appointments/$id/cancel', body: {'reason': reason});
    await load();
  }
}
