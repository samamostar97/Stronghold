import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool loginSuccess;
  final String? error;
  final String? adminName;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.loginSuccess = false,
    this.error,
    this.adminName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? loginSuccess,
    String? error,
    String? adminName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      error: error,
      adminName: adminName ?? this.adminName,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(username, password);
      final displayName = user['username'] as String;
      // Set loginSuccess but NOT isAuthenticated yet — let the screen animate first
      state = state.copyWith(
        isLoading: false,
        loginSuccess: true,
        adminName: displayName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void completeLogin() {
    state = state.copyWith(isAuthenticated: true);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  void checkAuth() {
    if (TokenStorage.isLoggedIn) {
      state = state.copyWith(isAuthenticated: true);
    }
  }
}
