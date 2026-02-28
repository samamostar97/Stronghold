import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Review service provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService(ref.watch(apiClientProvider));
});

/// Review list state provider
final reviewListProvider =
    StateNotifierProvider<
      ReviewListNotifier,
      ListState<ReviewResponse, ReviewQueryFilter>
    >((ref) {
      final service = ref.watch(reviewServiceProvider);
      return ReviewListNotifier(service);
    });

/// Review list notifier - read-only with delete support
class ReviewListNotifier
    extends StateNotifier<ListState<ReviewResponse, ReviewQueryFilter>> {
  final ReviewService _service;

  ReviewListNotifier(this._service)
    : super(ListState(filter: ReviewQueryFilter()));

  /// Load data from server with current filter
  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    } catch (e) {
      state = state.copyWithError('Greska pri ucitavanju: $e');
    }
  }

  /// Reload current page
  Future<void> refresh() => load();

  /// Update search and reload from page 1
  Future<void> setSearch(String? search) async {
    final normalizedSearch = search ?? '';
    final newFilter = _createFilterCopy(
      pageNumber: 1,
      search: normalizedSearch,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update sort order and reload from page 1
  Future<void> setOrderBy(String? orderBy) async {
    final normalizedOrderBy = orderBy ?? '';
    final newFilter = _createFilterCopy(
      pageNumber: 1,
      orderBy: normalizedOrderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = _createFilterCopy(pageNumber: page);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (state.hasNextPage) {
      await goToPage(state.currentPage + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (state.hasPreviousPage) {
      await goToPage(state.currentPage - 1);
    }
  }

  /// Update page size and reload from page 1
  Future<void> setPageSize(int pageSize) async {
    final newFilter = _createFilterCopy(pageNumber: 1, pageSize: pageSize);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Delete review and refresh list
  Future<void> delete(int id) async {
    await _service.delete(id);
    // If we deleted the last item on this page, go back one page
    if (state.items.length == 1 && state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    } else {
      await refresh();
    }
  }

  ReviewQueryFilter _createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null
        ? state.filter.search
        : (search.isEmpty ? null : search);
    return ReviewQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}

