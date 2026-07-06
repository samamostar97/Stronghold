import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../models/paged_result.dart';
import '../models/progress.dart';
import '../models/user_profile.dart';
import '../utils/api_client.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _api;

  ProfileProvider(this._api);

  UserProfile? _profile;
  Progress? _progress;
  int? _gymOccupancy;
  bool _loading = false;

  UserProfile? get profile => _profile;
  Progress? get progress => _progress;

  /// Broj clanova koji su trenutno u teretani (kartica na pocetnoj).
  int? get gymOccupancy => _gymOccupancy;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      // nezavisni pozivi idu paralelno
      final results = await Future.wait([
        _api.get('/api/profile'),
        _api.get('/api/profile/progress'),
        _api.get('/api/gym-visits/occupancy'),
      ]);
      _profile = UserProfile.fromJson(results[0] as Map<String, dynamic>);
      _progress = Progress.fromJson(results[1] as Map<String, dynamic>);
      _gymOccupancy =
          (results[2] as Map<String, dynamic>)['currentCount'] as int;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<City>> loadCities() async {
    final data = await _api.get('/api/cities', query: {
      'page': '1',
      'pageSize': '100',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, City.fromJson).items;
  }

  Future<void> update({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? streetAddress,
    int? cityId,
    String? imageBase64,
  }) async {
    final data = await _api.put('/api/profile', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'streetAddress': streetAddress,
      'cityId': cityId,
      'imageBase64': imageBase64,
    }) as Map<String, dynamic>;
    _profile = UserProfile.fromJson(data);
    notifyListeners();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.put('/api/profile/password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}
