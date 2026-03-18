import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';
import '../models/auth_response.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthState {
  final bool isAuthenticated;
  final UserResponse? user;

  const AuthState({this.isAuthenticated = false, this.user});

  String get displayName =>
      user != null ? '${user!.firstName} ${user!.lastName}' : '';
}

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void setAuth(AuthResponse auth) {
    TokenStorage.save(auth.accessToken, auth.refreshToken);
    state = AuthState(isAuthenticated: true, user: auth.user);
  }

  Future<void> logout() async {
    if (TokenStorage.refreshToken != null) {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout(TokenStorage.refreshToken!);
    }
    TokenStorage.clear();
    ApiClient.reset();
    state = const AuthState();
  }
}

final authStateProvider =
    NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);
