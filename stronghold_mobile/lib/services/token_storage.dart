import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'user_data';

  static Future<void> saveAuthData(AuthResponse authResponse) async {
    await _storage.write(key: _tokenKey, value: authResponse.token);
    await _storage.write(
      key: _userDataKey,
      value: jsonEncode({
        'userId': authResponse.userId,
        'firstName': authResponse.firstName,
        'lastName': authResponse.lastName,
        'username': authResponse.username,
        'email': authResponse.email,
        'profileImageUrl': authResponse.profileImageUrl,
        'hasActiveMembership': authResponse.hasActiveMembership,
      }),
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userDataKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userDataKey);
  }
}
