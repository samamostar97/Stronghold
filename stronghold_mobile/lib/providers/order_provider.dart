import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';

/// Order list state
class OrderListState {
  final List<UserOrderResponse> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool isLoading;
  final String? error;

  const OrderListState({
    this.items = const <UserOrderResponse>[],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.error,
  });

  OrderListState copyWith({
    List<UserOrderResponse>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderListState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;
}

/// Order list notifier - manages user's order history
class OrderListNotifier extends StateNotifier<OrderListState> {
  final UserOrderService _service;

  OrderListNotifier(this._service) : super(const OrderListState());

  /// Load user's orders
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getMyOrders(
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        items: result.items,
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja narudzbi',
        isLoading: false,
      );
    }
  }

  /// Go to next page (appends items for infinite scroll)
  Future<void> nextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final nextPageNumber = state.pageNumber + 1;
      final result = await _service.getMyOrders(
        pageNumber: nextPageNumber,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...result.items],
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja narudzbi',
        isLoading: false,
      );
    }
  }

  /// Refresh (resets to page 1)
  Future<void> refresh() async {
    state = state.copyWith(pageNumber: 1);
    await load();
  }
}

/// Order list provider
final orderListProvider =
    StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderListNotifier(UserOrderService(client));
});
