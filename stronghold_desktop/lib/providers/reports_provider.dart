import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Reports service provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref.watch(apiClientProvider));
});

/// Business report provider
final businessReportProvider = FutureProvider<BusinessReportDTO>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getBusinessReport();
});

/// Selected sales chart period (in days)
final salesPeriodProvider = StateProvider<int>((ref) => 30);

/// Daily sales data for the selected period
final salesChartDataProvider = FutureProvider<List<DailySalesDTO>>((ref) async {
  final days = ref.watch(salesPeriodProvider);
  final service = ref.watch(reportsServiceProvider);
  final report = await service.getBusinessReport(days: days);
  return report.dailySales;
});

/// Inventory report provider with configurable days parameter (legacy - loads all)
final inventoryReportProvider = FutureProvider.family<InventoryReportDTO, int>((
  ref,
  daysToAnalyze,
) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getInventoryReport(daysToAnalyze: daysToAnalyze);
});

/// Inventory summary provider (totals only, for header cards)
final inventorySummaryProvider =
    FutureProvider.family<InventorySummaryDTO, int>((ref, daysToAnalyze) async {
      final service = ref.watch(reportsServiceProvider);
      return service.getInventorySummary(daysToAnalyze: daysToAnalyze);
    });

/// Paginated slow-moving products state provider
final slowMovingProductsProvider =
    StateNotifierProvider<
      SlowMovingProductsNotifier,
      ListState<SlowMovingProductDTO, SlowMovingProductQueryFilter>
    >((ref) {
      final service = ref.watch(reportsServiceProvider);
      return SlowMovingProductsNotifier(service);
    });

/// Slow-moving products list notifier with pagination
class SlowMovingProductsNotifier
    extends
        StateNotifier<
          ListState<SlowMovingProductDTO, SlowMovingProductQueryFilter>
        > {
  final ReportsService _service;

  SlowMovingProductsNotifier(this._service)
    : super(ListState(filter: SlowMovingProductQueryFilter(pageSize: 10)));

  /// Load data from server with current filter
  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getSlowMovingProductsPaged(state.filter);
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
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      search: normalizedSearch,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update sort order and reload from page 1
  Future<void> setOrderBy(String? orderBy) async {
    final normalizedOrderBy = orderBy ?? '';
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      orderBy: normalizedOrderBy,
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
    final newFilter = state.filter.copyWith(pageNumber: 1, pageSize: pageSize);
    state = state.copyWithFilter(newFilter);
    await load();
  }

  /// Update days to analyze and reload from page 1
  Future<void> setDaysToAnalyze(int days) async {
    if (state.filter.daysToAnalyze == days) {
      if (state.data == null && !state.isLoading) {
        await load();
      }
      return;
    }

    final newFilter = state.filter.copyWith(pageNumber: 1, daysToAnalyze: days);
    state = state.copyWithFilter(newFilter);
    await load();
  }
}

/// Selected membership revenue period (in days)
final membershipRevenuePeriodProvider = StateProvider<int>((ref) => 90);

/// Membership popularity report provider (reacts to period change)
final membershipPopularityReportProvider =
    FutureProvider<MembershipPopularityReportDTO>((ref) async {
      final days = ref.watch(membershipRevenuePeriodProvider);
      final service = ref.watch(reportsServiceProvider);
      return service.getMembershipPopularityReport(days: days);
    });

/// Export operations notifier for handling export state
class ExportOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final ReportsService _service;

  ExportOperationsNotifier(this._service) : super(const AsyncValue.data(null));

  bool get isExporting => state.isLoading;

  Future<void> exportBusinessToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportBusinessToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportBusinessToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportBusinessToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportInventoryToExcel(
    String savePath, {
    int daysToAnalyze = 30,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportInventoryToExcel(
        savePath,
        daysToAnalyze: daysToAnalyze,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportInventoryToPdf(
    String savePath, {
    int daysToAnalyze = 30,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportInventoryToPdf(
        savePath,
        daysToAnalyze: daysToAnalyze,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Export operations provider
final exportOperationsProvider =
    StateNotifierProvider<ExportOperationsNotifier, AsyncValue<void>>((ref) {
      final service = ref.watch(reportsServiceProvider);
      return ExportOperationsNotifier(service);
    });
