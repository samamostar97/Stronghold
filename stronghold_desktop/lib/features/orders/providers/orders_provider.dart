import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/orders_repository.dart';
import '../models/order_response.dart';

final ordersRepositoryProvider = Provider((ref) => OrdersRepository());

// Filter state
class OrdersFilter {
  final int pageNumber;
  final String? search;
  final String? statusFilter;

  const OrdersFilter({
    this.pageNumber = 1,
    this.search,
    this.statusFilter,
  });

  OrdersFilter copyWith({
    int? pageNumber,
    String? search,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return OrdersFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

// Active orders filter notifier
class OrdersFilterNotifier extends Notifier<OrdersFilter> {
  @override
  OrdersFilter build() => const OrdersFilter();

  void update(OrdersFilter filter) => state = filter;
}

final ordersFilterProvider =
    NotifierProvider<OrdersFilterNotifier, OrdersFilter>(OrdersFilterNotifier.new);

// Order history filter notifier
class OrderHistoryFilterNotifier extends Notifier<OrdersFilter> {
  @override
  OrdersFilter build() => const OrdersFilter();

  void update(OrdersFilter filter) => state = filter;
}

final orderHistoryFilterProvider =
    NotifierProvider<OrderHistoryFilterNotifier, OrdersFilter>(OrderHistoryFilterNotifier.new);

// Active orders data (Pending + Confirmed)
final ordersProvider = FutureProvider.autoDispose<PagedOrderResponse>((ref) async {
  final repo = ref.read(ordersRepositoryProvider);
  final filter = ref.watch(ordersFilterProvider);

  if (filter.statusFilter != null) {
    return repo.getOrders(
      pageNumber: filter.pageNumber,
      search: filter.search,
      status: filter.statusFilter,
      orderBy: 'status',
      orderDescending: false,
    );
  }

  // No filter — fetch Pending first, then Confirmed
  final pendingResult = await repo.getOrders(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'Pending',
    orderDescending: true,
  );

  final confirmedResult = await repo.getOrders(
    pageNumber: 1,
    pageSize: 100,
    search: filter.search,
    status: 'Confirmed',
    orderDescending: true,
  );

  final allItems = [...pendingResult.items, ...confirmedResult.items];
  final totalCount = pendingResult.totalCount + confirmedResult.totalCount;

  return PagedOrderResponse(
    items: allItems,
    totalCount: totalCount,
    currentPage: filter.pageNumber,
    totalPages: (totalCount / 10).ceil(),
    pageSize: 10,
  );
});

// Order history data (Shipped)
final orderHistoryProvider = FutureProvider.autoDispose<PagedOrderResponse>((ref) async {
  final repo = ref.read(ordersRepositoryProvider);
  final filter = ref.watch(orderHistoryFilterProvider);

  return repo.getOrders(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'Shipped',
    orderDescending: true,
  );
});
