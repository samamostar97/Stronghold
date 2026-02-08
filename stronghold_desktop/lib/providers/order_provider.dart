import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Order service provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(apiClientProvider));
});

/// Order list state provider
final orderListProvider = StateNotifierProvider<
    OrderListNotifier,
    ListState<OrderResponse, OrderQueryFilter>>((ref) {
  final service = ref.watch(orderServiceProvider);
  return OrderListNotifier(service);
});

/// Order list notifier implementation.
/// Custom implementation since orders are read-only (no create/update).
class OrderListNotifier
    extends StateNotifier<ListState<OrderResponse, OrderQueryFilter>> {
  final OrderService _service;

  OrderListNotifier(this._service)
      : super(ListState(filter: OrderQueryFilter()));

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
    // null = keep old value, '' = clear search, 'value' = new search
    // copyWith uses ?? so we need to create a new filter when clearing
    OrderQueryFilter newFilter;
    if (search?.isEmpty == true) {
      // Clear search - create new filter without search
      newFilter = OrderQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        orderBy: state.filter.orderBy,
        status: state.filter.status,
        dateFrom: state.filter.dateFrom,
        dateTo: state.filter.dateTo,
        descending: state.filter.descending,
        // search is null (cleared)
      );
    } else {
      newFilter = state.filter.copyWith(
        pageNumber: 1,
        search: search,
      );
    }
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update sort order and reload from page 1
  Future<void> setOrderBy(String? orderBy) async {
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      orderBy: orderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update status filter and reload from page 1
  Future<void> setStatus(OrderStatus? status) async {
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      status: status,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = state.filter.copyWith(pageNumber: page);
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
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      pageSize: pageSize,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Mark an order as delivered and refresh the list
  Future<void> markAsDelivered(int orderId) async {
    await _service.markAsDelivered(orderId);
    // Don't await - refresh in background so success shows immediately
    refresh();
  }
}
