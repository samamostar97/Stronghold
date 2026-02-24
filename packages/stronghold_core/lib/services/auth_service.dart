import '../api/api_client.dart';
import '../models/responses/auth_response.dart';
import '../storage/token_storage.dart';

class AuthService {
  static const String _basePath = '/api/auth';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      final data = await c.post<Map<String, dynamic>>(
        '$_basePath/login/admin',
        body: {'username': username, 'password': password},
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );
      await TokenStorage.saveLogin(data);
      return data;
    } finally {
      if (client == null) c.dispose();
    }
  }

  static Future<void> logout() => TokenStorage.clear();

  /// Login as member (mobile app)
  static Future<AuthResponse> loginMember({
    required String username,
    required String password,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      final response = await c.post<Map<String, dynamic>>(
        '$_basePath/login/member',
        body: {'username': username, 'password': password},
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );
      final authResponse = AuthResponse.fromJson(response);
      await TokenStorage.saveLogin(response);
      return authResponse;
    } finally {
      if (client == null) c.dispose();
    }
  }

  /// Register a new member
  static Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      final response = await c.post<Map<String, dynamic>>(
        '$_basePath/register',
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );
      final authResponse = AuthResponse.fromJson(response);
      await TokenStorage.saveLogin(response);
      return authResponse;
    } finally {
      if (client == null) c.dispose();
    }
  }

  /// Request password reset code
  static Future<void> forgotPassword({
    required String email,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      await c.post<void>(
        '$_basePath/forgot-password',
        body: {'email': email},
        parser: (_) {},
        requiresAuth: false,
      );
    } finally {
      if (client == null) c.dispose();
    }
  }

  /// Reset password with verification code
  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      await c.post<void>(
        '$_basePath/reset-password',
        body: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
        parser: (_) {},
        requiresAuth: false,
      );
    } finally {
      if (client == null) c.dispose();
    }
  }

  /// Change password (authenticated)
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    ApiClient? client,
  }) async {
    final c = client ?? ApiClient();
    try {
      await c.put<void>(
        '$_basePath/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        parser: (_) {},
      );
    } finally {
      if (client == null) c.dispose();
    }
  }
}
