import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

final adminActivityServiceProvider = Provider<AdminActivityService>((ref) {
  return AdminActivityService(ref.watch(apiClientProvider));
});

class AdminActivityState {
  final List<AdminActivityResponse> items;
  final bool isLoading;
  final Set<int> undoInProgressIds;
  final String? error;

  const AdminActivityState({
    this.items = const [],
    this.isLoading = false,
    this.undoInProgressIds = const {},
    this.error,
  });

  AdminActivityState copyWith({
    List<AdminActivityResponse>? items,
    bool? isLoading,
    Set<int>? undoInProgressIds,
    String? error,
  }) {
    return AdminActivityState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      undoInProgressIds: undoInProgressIds ?? this.undoInProgressIds,
      error: error,
    );
  }
}

final adminActivityProvider =
    StateNotifierProvider<AdminActivityNotifier, AdminActivityState>((ref) {
      return AdminActivityNotifier(ref.watch(adminActivityServiceProvider));
    });

class AdminActivityNotifier extends StateNotifier<AdminActivityState> {
  final AdminActivityService _service;

  AdminActivityNotifier(this._service) : super(const AdminActivityState());

  Future<void> load({int count = 20}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _service.getRecent(count: count);
      if (mounted) {
        state = state.copyWith(items: items, isLoading: false, error: null);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> undo(int id) async {
    if (state.undoInProgressIds.contains(id)) return;

    final inProgress = Set<int>.from(state.undoInProgressIds)..add(id);
    state = state.copyWith(undoInProgressIds: inProgress, error: null);

    try {
      final updated = await _service.undo(id);
      if (!mounted) return;

      final items = state.items
          .map((x) => x.id == id ? updated : x)
          .toList(growable: false);

      final done = Set<int>.from(state.undoInProgressIds)..remove(id);
      state = state.copyWith(
        items: items,
        undoInProgressIds: done,
        error: null,
      );
    } catch (e) {
      if (mounted) {
        final done = Set<int>.from(state.undoInProgressIds)..remove(id);
        state = state.copyWith(undoInProgressIds: done, error: e.toString());
      }
      rethrow;
    }
  }
}
