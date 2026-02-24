import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Seminars state
class SeminarsState {
  final List<UserSeminarResponse> items;
  final bool isLoading;
  final String? error;

  const SeminarsState({
    this.items = const <UserSeminarResponse>[],
    this.isLoading = false,
    this.error,
  });

  SeminarsState copyWith({
    List<UserSeminarResponse>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SeminarsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Seminars notifier
class SeminarsNotifier extends StateNotifier<SeminarsState> {
  final UserSeminarService _service;

  SeminarsNotifier(this._service) : super(const SeminarsState());

  /// Load upcoming seminars
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final seminars = await _service.getUpcoming();
      state = state.copyWith(items: seminars, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja seminara',
        isLoading: false,
      );
    }
  }

  /// Attend seminar
  Future<void> attend(int id) async {
    try {
      await _service.attend(id);
      await load(); // Refresh list
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    }
  }

  /// Cancel attendance
  Future<void> cancelAttendance(int id) async {
    try {
      await _service.cancelAttendance(id);
      await load(); // Refresh list
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    }
  }

  /// Refresh
  Future<void> refresh() => load();
}

/// Seminars provider
final seminarsProvider =
    StateNotifierProvider<SeminarsNotifier, SeminarsState>((ref) {
  final client = ref.watch(apiClientProvider);
  return SeminarsNotifier(UserSeminarService(client));
});
