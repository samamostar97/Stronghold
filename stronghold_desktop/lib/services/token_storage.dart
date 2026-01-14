import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _s = FlutterSecureStorage();

  static const _kAccessToken = 'accessToken';
  static const _kRefreshToken = 'refreshToken';
  static const _kAccessExpiry = 'accessTokenExpiry';
  static const _kRefreshExpiry = 'refreshTokenExpiry';
  static const _kRole = 'role';

  static Future<void> saveLogin(Map<String, dynamic> json) async {
    await _s.write(key: _kAccessToken, value: json['token']?.toString());
    await _s.write(key: _kRefreshToken, value: json['refreshToken']?.toString());
    await _s.write(key: _kAccessExpiry, value: json['accessTokenExpiry']?.toString());
    await _s.write(key: _kRefreshExpiry, value: json['refreshTokenExpiry']?.toString());
    await _s.write(key: _kRole, value: json['role']?.toString());
  }

  static Future<String?> accessToken() => _s.read(key: _kAccessToken);
  static Future<String?> refreshToken() => _s.read(key: _kRefreshToken);
  static Future<String?> role() => _s.read(key: _kRole);

  static Future<void> clear() => _s.deleteAll();
}
