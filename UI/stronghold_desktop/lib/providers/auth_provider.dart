import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../utils/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;

  AuthUser? _user;
  bool _loading = false;

  AuthProvider(this._api) {
    _api.onSessionExpired = _handleSessionExpired;
  }

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  Future<void> login(String usernameOrEmail, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/api/auth/login', body: {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }) as Map<String, dynamic>;

      final user = AuthUser.fromJson(data);
      if (user.role != 'Admin') {
        throw ApiException(403, 'Pristup desktop aplikaciji ima samo administrator.');
      }

      _api.setTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      _user = user;
    } finally {
      _loading = false;
      notifyListeners();
    }
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
    _user = null;
    notifyListeners();
  }

  void _handleSessionExpired() {
    _user = null;
    notifyListeners();
  }
}
