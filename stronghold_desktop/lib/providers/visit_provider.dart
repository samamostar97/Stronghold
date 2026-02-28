import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Visit service provider
final visitServiceProvider = Provider<VisitService>((ref) {
  return VisitService(ref.watch(apiClientProvider));
});

/// Current visitors provider (server-side pagination/filter/sort)
final currentVisitorsProvider =
    StateNotifierProvider<
      CurrentVisitorsNotifier,
      ListState<CurrentVisitorResponse, VisitQueryFilter>
    >((ref) {
      final service = ref.watch(visitServiceProvider);
      return CurrentVisitorsNotifier(service);
    });

/// Current visitors notifier
class CurrentVisitorsNotifier
    extends StateNotifier<ListState<CurrentVisitorResponse, VisitQueryFilter>> {
  final VisitService _service;

  CurrentVisitorsNotifier(this._service)
    : super(
        ListState(
          filter: VisitQueryFilter(pageSize: 10, orderBy: 'checkindesc'),
        ),
      );

  /// Load current visitors
  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getCurrentVisitorsPaged(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    } catch (e) {
      state = state.copyWithError('Greska pri ucitavanju: $e');
    }
  }

  /// Refresh current page
  Future<void> refresh() => load();

  /// Update search and reload from page 1
  Future<void> setSearch(String? search) async {
    final normalizedSearch = search ?? '';
    final nextSearch = normalizedSearch;
    final newFilter = state.filter.copyWith(pageNumber: 1, search: nextSearch);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update sort and reload from page 1
  Future<void> setOrderBy(String? orderBy) async {
    final normalizedOrderBy = orderBy ?? '';
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      orderBy: normalizedOrderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Go to page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = state.filter.copyWith(pageNumber: page);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Check in a user
  Future<void> checkIn(int userId) async {
    await _service.checkIn(CheckInRequest(userId: userId));
    await load();
  }

  /// Check out a visitor
  Future<void> checkOut(int visitId) async {
    await _service.checkOut(visitId);

    if (state.items.length == 1 && state.currentPage > 1) {
      final previousPageFilter = state.filter.copyWith(
        pageNumber: state.currentPage - 1,
      );
      state = state.copyWithFilter(previousPageFilter);
    }

    await load();
  }
}
