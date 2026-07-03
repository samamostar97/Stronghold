import 'package:flutter/foundation.dart';

import '../models/member.dart';
import '../utils/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;

  Member? _member;
  bool _loading = false;

  AuthProvider(this._api) {
    _api.onSessionExpired = _handleSessionExpired;
  }

  Member? get member => _member;
  bool get isLoggedIn => _member != null;
  bool get loading => _loading;

  Future<void> login(String usernameOrEmail, String password) async {
    await _authenticate(() => _api.post('/api/auth/login', body: {
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }));
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _authenticate(() => _api.post('/api/auth/register', body: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
        }));
  }

  Future<void> logout() async {
    final refreshToken = _api.refreshToken;
    if (refreshToken != null) {
      try {
        await _api.post('/api/auth/logout', body: {'refreshToken': refreshToken});
      } on ApiException {
        // logout ne smije zapeti zbog mrezne greske - tokeni se svakako brisu
      }
    }
    _api.clearTokens();
    _member = null;
    notifyListeners();
  }

  Future<void> _authenticate(Future<dynamic> Function() request) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await request() as Map<String, dynamic>;
      final member = Member.fromJson(data);
      if (member.role != 'GymMember') {
        throw ApiException(403, 'Mobilna aplikacija je namijenjena članovima teretane.');
      }
      _api.setTokens(
        accessToken: member.accessToken,
        refreshToken: member.refreshToken,
      );
      _member = member;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _handleSessionExpired() {
    _member = null;
    notifyListeners();
  }
}
