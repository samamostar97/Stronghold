import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/auth_models.dart';
import 'api_providers.dart';

/// Auth state
class AuthState {
  final AuthResponse? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthResponse? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isAuthenticated => user != null;
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _client;

  AuthNotifier(this._client) : super(const AuthState());

  /// Login user (member-specific endpoint)
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/Auth/login/member',
        body: {
          'username': username,
          'password': password,
        },
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );

      final authResponse = AuthResponse.fromJson(response);
      await TokenStorage.saveLogin({'token': authResponse.token});
      state = state.copyWith(user: authResponse, isLoading: false);
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        state = state.copyWith(
          error: 'Administratori koriste desktop aplikaciju.',
          isLoading: false,
        );
      } else if (e.statusCode == 401) {
        state = state.copyWith(
          error: 'Neispravan username ili lozinka',
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: e.message, isLoading: false);
      }
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom prijave. Pokusajte ponovo.',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Register new user
  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/Auth/register',
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
      await TokenStorage.saveLogin({'token': authResponse.token});
      state = state.copyWith(user: authResponse, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom registracije. Pokusajte ponovo.',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Forgot password - request reset code
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.post<void>(
        '/api/Auth/forgot-password',
        body: {'email': email},
        parser: (_) {},
        requiresAuth: false,
      );
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom slanja koda. Pokusajte ponovo.',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Reset password with code
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.post<void>(
        '/api/Auth/reset-password',
        body: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
        parser: (_) {},
        requiresAuth: false,
      );
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        state = state.copyWith(
          error: 'Kod je nevazeci ili je istekao',
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: e.message, isLoading: false);
      }
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom resetovanja lozinke. Pokusajte ponovo.',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Change password (authenticated)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.put<void>(
        '/api/Auth/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        parser: (_) {},
      );
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        state = state.copyWith(
          error: 'Trenutna lozinka nije ispravna',
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: e.message, isLoading: false);
      }
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom promjene lozinke. Pokusajte ponovo.',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Update profile image URL in auth state
  void updateProfileImage(String? url) {
    final current = state.user;
    if (current == null) return;
    state = state.copyWith(user: current.copyWithImage(url));
  }

  /// Logout
  Future<void> logout() async {
    await TokenStorage.clear();
    state = state.copyWith(clearUser: true, clearError: true);
  }

  /// Check if user is logged in (restore session)
  Future<bool> checkAuth() async {
    final token = await TokenStorage.accessToken();
    if (token == null) {
      state = state.copyWith(clearUser: true);
      return false;
    }
    return true;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthNotifier(client);
});
