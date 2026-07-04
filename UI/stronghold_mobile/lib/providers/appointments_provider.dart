import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/paged_result.dart';
import '../models/staff_member.dart';
import '../utils/api_client.dart';

class AppointmentsProvider extends ChangeNotifier {
  final ApiClient _api;

  AppointmentsProvider(this._api);

  List<Appointment> _appointments = [];
  bool _loading = false;

  List<Appointment> get appointments => _appointments;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/appointments/my', query: {
        'page': '1',
        'pageSize': '50',
      }) as Map<String, dynamic>;
      _appointments = PagedResult.fromJson(data, Appointment.fromJson).items;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Osoblje za booking - treneri i nutricionisti.
  Future<List<StaffMember>> loadStaff() async {
    final data = await _api.get('/api/staff-members', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, StaffMember.fromJson).items;
  }

  /// Slobodne satnice za odabranu osobu i datum - dropdown filtrira zauzete.
  Future<List<int>> loadFreeSlots(int staffMemberId, DateTime date) async {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data = await _api.get('/api/appointments/free-slots', query: {
      'staffMemberId': '$staffMemberId',
      'date': formatted,
    }) as List;
    return data.cast<int>();
  }

  Future<void> book({
    required int staffMemberId,
    required DateTime date,
    required int startHour,
  }) async {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _api.post('/api/appointments/my', body: {
      'staffMemberId': staffMemberId,
      'date': formatted,
      'startHour': startHour,
    });
    await load();
  }

  Future<void> cancel(int id, String reason) async {
    await _api.put('/api/appointments/$id/cancel', body: {'reason': reason});
    await load();
  }
}
