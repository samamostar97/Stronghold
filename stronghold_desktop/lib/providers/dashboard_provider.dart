import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';
import 'visit_provider.dart';

/// Aggregated dashboard state with per-section loading/error.
class DashboardState {
  static const _noChange = Object();

  final DashboardOverviewDTO? overview;
  final DashboardSalesDTO? salesReport;
  final List<CurrentVisitorResponse> currentVisitors;

  final bool isOverviewLoading;
  final bool isSalesLoading;
  final bool isVisitorsLoading;

  final String? overviewError;
  final String? salesError;
  final String? visitorsError;

  const DashboardState({
    this.overview,
    this.salesReport,
    this.currentVisitors = const [],
    this.isOverviewLoading = false,
    this.isSalesLoading = false,
    this.isVisitorsLoading = false,
    this.overviewError,
    this.salesError,
    this.visitorsError,
  });

  bool get isAnyLoading =>
      isOverviewLoading || isSalesLoading || isVisitorsLoading;

  DashboardState copyWith({
    Object? overview = _noChange,
    Object? salesReport = _noChange,
    List<CurrentVisitorResponse>? currentVisitors,
    bool? isOverviewLoading,
    bool? isSalesLoading,
    bool? isVisitorsLoading,
    Object? overviewError = _noChange,
    Object? salesError = _noChange,
    Object? visitorsError = _noChange,
  }) {
    return DashboardState(
      overview: identical(overview, _noChange)
          ? this.overview
          : overview as DashboardOverviewDTO?,
      salesReport: identical(salesReport, _noChange)
          ? this.salesReport
          : salesReport as DashboardSalesDTO?,
      currentVisitors: currentVisitors ?? this.currentVisitors,
      isOverviewLoading: isOverviewLoading ?? this.isOverviewLoading,
      isSalesLoading: isSalesLoading ?? this.isSalesLoading,
      isVisitorsLoading: isVisitorsLoading ?? this.isVisitorsLoading,
      overviewError: identical(overviewError, _noChange)
          ? this.overviewError
          : overviewError as String?,
      salesError: identical(salesError, _noChange)
          ? this.salesError
          : salesError as String?,
      visitorsError: identical(visitorsError, _noChange)
          ? this.visitorsError
          : visitorsError as String?,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _dashboardService;
  final VisitService _visitService;

  DashboardNotifier(this._dashboardService, this._visitService)
    : super(const DashboardState());

  Future<void> load() async {
    state = state.copyWith(
      isOverviewLoading: true,
      isSalesLoading: true,
      isVisitorsLoading: true,
      overviewError: null,
      salesError: null,
      visitorsError: null,
    );

    await Future.wait([_loadOverview(), _loadSales(), _loadVisitors()]);
  }

  Future<void> refresh() => load();

  Future<void> reloadOverview() async {
    state = state.copyWith(isOverviewLoading: true, overviewError: null);
    await _loadOverview();
  }

  Future<void> reloadSales() async {
    state = state.copyWith(isSalesLoading: true, salesError: null);
    await _loadSales();
  }

  Future<void> reloadVisitors() async {
    state = state.copyWith(isVisitorsLoading: true, visitorsError: null);
    await _loadVisitors();
  }

  Future<void> _loadOverview() async {
    try {
      final overview = await _dashboardService.getOverview();
      if (!mounted) return;
      state = state.copyWith(
        overview: overview,
        isOverviewLoading: false,
        overviewError: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isOverviewLoading: false,
        overviewError: _message(e),
      );
    }
  }

  Future<void> _loadSales() async {
    try {
      final sales = await _dashboardService.getSales();
      if (!mounted) return;
      state = state.copyWith(
        salesReport: sales,
        isSalesLoading: false,
        salesError: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isSalesLoading: false, salesError: _message(e));
    }
  }

  Future<void> _loadVisitors() async {
    try {
      final visitors = await _visitService.getCurrentVisitors();
      if (!mounted) return;
      state = state.copyWith(
        currentVisitors: visitors,
        isVisitorsLoading: false,
        visitorsError: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isVisitorsLoading: false,
        visitorsError: _message(e),
      );
    }
  }

  static String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(apiClientProvider));
});

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final dashboardService = ref.watch(dashboardServiceProvider);
      final visitService = ref.watch(visitServiceProvider);
      return DashboardNotifier(dashboardService, visitService);
    });
