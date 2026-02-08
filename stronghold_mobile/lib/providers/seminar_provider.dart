import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/seminar.dart';
import 'api_providers.dart';

/// Seminars state
class SeminarsState {
  final List<Seminar> items;
  final bool isLoading;
  final String? error;

  const SeminarsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  SeminarsState copyWith({
    List<Seminar>? items,
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
  final ApiClient _client;

  SeminarsNotifier(this._client) : super(const SeminarsState());

  /// Load upcoming seminars
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final seminars = await _client.get<List<Seminar>>(
        '/api/seminar/upcoming',
        parser: (json) => (json as List<dynamic>)
            .map((j) => Seminar.fromJson(j as Map<String, dynamic>))
            .toList(),
      );
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
      await _client.post<void>(
        '/api/seminar/$id/attend',
        parser: (_) {},
      );
      await load(); // Refresh list
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    }
  }

  /// Cancel attendance
  Future<void> cancelAttendance(int id) async {
    try {
      await _client.delete('/api/seminar/$id/attend');
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
  return SeminarsNotifier(client);
});
