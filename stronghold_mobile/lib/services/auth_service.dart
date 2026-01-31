import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_models.dart';
import 'token_storage.dart';

class AuthService {
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(LoginRequest(
        username: username,
        password: password,
      ).toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      await TokenStorage.saveAuthData(authResponse);
      return authResponse;
    } else if (response.statusCode == 401) {
      throw AuthException('Neispravan username ili lozinka');
    } else {
      throw AuthException('Greska prilikom prijave. Pokusajte ponovo.');
    }
  }

  static Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ).toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      await TokenStorage.saveAuthData(authResponse);
      return authResponse;
    } else if (response.statusCode == 409) {
      // Conflict - username, email, or phone already exists
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = data['error'] as String? ?? 'Podaci vec postoje';
      throw AuthException(errorMessage);
    } else if (response.statusCode == 400) {
      // Validation error
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = data['error'] as String? ?? 'Neispravni podaci';
        throw AuthException(errorMessage);
      } catch (_) {
        throw AuthException('Neispravni podaci. Provjerite unos.');
      }
    } else {
      throw AuthException('Greska prilikom registracije. Pokusajte ponovo.');
    }
  }

  static Future<void> forgotPassword({required String email}) async {
    final response = await http.post(
      ApiConfig.uri('/api/Auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw AuthException('Greska prilikom slanja koda. Pokusajte ponovo.');
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/Auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw AuthException('Kod je nevažeći ili je istekao');
    } else {
      throw AuthException('Greska prilikom resetovanja lozinke. Pokusajte ponovo.');
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clear();
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw AuthException('Niste prijavljeni');
    }

    final response = await http.put(
      ApiConfig.uri('/api/Auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = data['error'] as String? ?? 'Trenutna lozinka nije ispravna';
        throw AuthException(errorMessage);
      } catch (e) {
        if (e is AuthException) rethrow;
        throw AuthException('Trenutna lozinka nije ispravna');
      }
    } else if (response.statusCode == 400) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = data['error'] as String? ?? 'Neispravni podaci';
        throw AuthException(errorMessage);
      } catch (e) {
        if (e is AuthException) rethrow;
        throw AuthException('Neispravni podaci. Provjerite unos.');
      }
    } else {
      throw AuthException('Greska prilikom promjene lozinke. Pokusajte ponovo.');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
