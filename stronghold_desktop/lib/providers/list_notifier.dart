import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'list_state.dart';

/// Generic list notifier for CRUD entities with server-side pagination/filtering/sorting
abstract class ListNotifier<
  T,
  TCreate,
  TUpdate,
  TFilter extends BaseQueryFilter
>
    extends StateNotifier<ListState<T, TFilter>> {
  final Future<PagedResult<T>> Function(TFilter filter) _getAll;
  final Future<int> Function(TCreate request) _create;
  final Future<void> Function(int id, TUpdate request) _update;
  final Future<void> Function(int id) _delete;

  ListNotifier({
    required Future<PagedResult<T>> Function(TFilter filter) getAll,
    required Future<int> Function(TCreate request) create,
    required Future<void> Function(int id, TUpdate request) update,
    required Future<void> Function(int id) delete,
    required TFilter initialFilter,
  }) : _getAll = getAll,
       _create = create,
       _update = update,
       _delete = delete,
       super(ListState(filter: initialFilter));

  /// Load data from server with current filter
  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _getAll(state.filter);
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
    final newFilter = createFilterCopy(pageNumber: 1, search: normalizedSearch);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update sort order and reload from page 1
  Future<void> setOrderBy(String? orderBy) async {
    final normalizedOrderBy = orderBy ?? '';
    final newFilter = createFilterCopy(
      pageNumber: 1,
      orderBy: normalizedOrderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = createFilterCopy(pageNumber: page);
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
    final newFilter = createFilterCopy(pageNumber: 1, pageSize: pageSize);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Create entity and refresh list
  Future<int> create(TCreate request) async {
    final id = await _create(request);
    await refresh();
    return id;
  }

  /// Update entity and refresh list
  Future<void> update(int id, TUpdate request) async {
    await _update(id, request);
    await refresh();
  }

  /// Delete entity and refresh list
  Future<void> delete(int id) async {
    await _delete(id);
    // If we deleted the last item on this page, go back one page
    if (state.items.length == 1 && state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    } else {
      await refresh();
    }
  }

  /// Create a copy of filter with updated values - must be implemented by subclass
  TFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  });
}
