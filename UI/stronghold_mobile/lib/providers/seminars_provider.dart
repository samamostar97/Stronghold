import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/seminar.dart';
import '../utils/api_client.dart';

class SeminarsProvider extends ChangeNotifier {
  final ApiClient _api;

  SeminarsProvider(this._api);

  List<Seminar> _seminars = [];
  bool _loading = false;

  List<Seminar> get seminars => _seminars;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/seminars', query: {
        'page': '1',
        'pageSize': '50',
        'onlyUpcoming': 'true',
      }) as Map<String, dynamic>;
      _seminars = PagedResult.fromJson(data, Seminar.fromJson).items;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Prijava jednim klikom - kapacitet i duplikat provjerava backend.
  Future<void> register(int seminarId) async {
    await _api.post('/api/seminars/$seminarId/register');
    await load();
  }

  /// Odjava oslobadja mjesto - moguca do pocetka seminara.
  Future<void> unregister(int seminarId) async {
    await _api.post('/api/seminars/$seminarId/unregister');
    await load();
  }
}
