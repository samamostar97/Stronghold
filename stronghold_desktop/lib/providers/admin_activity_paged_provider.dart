import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'admin_activity_provider.dart';
import 'list_state.dart';

class AdminActivityPagedState {
  final ListState<AdminActivityResponse, AdminActivityQueryFilter> list;
  final Set<int> undoInProgressIds;

  const AdminActivityPagedState({
    required this.list,
    this.undoInProgressIds = const {},
  });

  AdminActivityPagedState copyWith({
    ListState<AdminActivityResponse, AdminActivityQueryFilter>? list,
    Set<int>? undoInProgressIds,
  }) {
    return AdminActivityPagedState(
      list: list ?? this.list,
      undoInProgressIds: undoInProgressIds ?? this.undoInProgressIds,
    );
  }

  // Convenience getters
  List<AdminActivityResponse> get items => list.items;
  int get totalCount => list.totalCount;
  int get currentPage => list.currentPage;
  int get totalPages => list.totalPages;
  bool get isLoading => list.isLoading;
  String? get error => list.error;
}

final adminActivityPagedProvider = StateNotifierProvider<
    AdminActivityPagedNotifier, AdminActivityPagedState>((ref) {
  final service = ref.watch(adminActivityServiceProvider);
  return AdminActivityPagedNotifier(service);
});

class AdminActivityPagedNotifier
    extends StateNotifier<AdminActivityPagedState> {
  final AdminActivityService _service;

  AdminActivityPagedNotifier(this._service)
      : super(AdminActivityPagedState(
          list: ListState(
            filter: AdminActivityQueryFilter(pageSize: 20),
          ),
        ));

  Future<void> load() async {
    state = state.copyWith(list: state.list.copyWithLoading());
    try {
      final result = await _service.getPaged(state.list.filter);
      if (mounted) {
        state = state.copyWith(list: state.list.copyWithData(result));
      }
    } on ApiException catch (e) {
      if (mounted) {
        state = state.copyWith(list: state.list.copyWithError(e.message));
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
            list: state.list.copyWithError('Greska pri ucitavanju: $e'));
      }
    }
  }

  Future<void> setSearch(String? search) async {
    final newFilter = state.list.filter.copyWith(
      pageNumber: 1,
      search: search ?? '',
    );
    state = state.copyWith(list: state.list.copyWithFilter(newFilter));
    await load();
  }

  Future<void> setOrderBy(String? orderBy) async {
    final newFilter = state.list.filter.copyWith(
      pageNumber: 1,
      orderBy: orderBy ?? '',
    );
    state = state.copyWith(list: state.list.copyWithFilter(newFilter));
    await load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = state.list.filter.copyWith(pageNumber: page);
    state = state.copyWith(list: state.list.copyWithFilter(newFilter));
    await load();
  }

  Future<void> undo(int id) async {
    if (state.undoInProgressIds.contains(id)) return;

    final inProgress = Set<int>.from(state.undoInProgressIds)..add(id);
    state = state.copyWith(undoInProgressIds: inProgress);

    try {
      final updated = await _service.undo(id);
      if (!mounted) return;

      final items = state.items
          .map((x) => x.id == id ? updated : x)
          .toList(growable: false);

      final done = Set<int>.from(state.undoInProgressIds)..remove(id);
      final newData = PagedResult<AdminActivityResponse>(
        items: items,
        totalCount: state.totalCount,
        pageNumber: state.currentPage,
      );
      state = state.copyWith(
        list: state.list.copyWithData(newData),
        undoInProgressIds: done,
      );
    } catch (e) {
      if (mounted) {
        final done = Set<int>.from(state.undoInProgressIds)..remove(id);
        state = state.copyWith(undoInProgressIds: done);
      }

      // Refresh to stay in sync
      if (mounted) {
        try {
          await load();
        } catch (_) {}
      }

      rethrow;
    }
  }
}
