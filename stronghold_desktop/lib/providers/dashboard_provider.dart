import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'visit_provider.dart';

/// Aggregated dashboard state composing data from multiple services.
class DashboardState {
  final BusinessReportDTO? businessReport;
  final DashboardSalesDTO? salesReport;
  final List<CurrentVisitorResponse> currentVisitors;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.businessReport,
    this.salesReport,
    this.currentVisitors = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    BusinessReportDTO? businessReport,
    DashboardSalesDTO? salesReport,
    List<CurrentVisitorResponse>? currentVisitors,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      businessReport: businessReport ?? this.businessReport,
      salesReport: salesReport ?? this.salesReport,
      currentVisitors: currentVisitors ?? this.currentVisitors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Dashboard notifier that fetches data from existing services in parallel.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _dashboardService;
  final VisitService _visitService;

  DashboardNotifier(this._dashboardService, this._visitService)
    : super(const DashboardState());

  /// Load all dashboard data in parallel.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _dashboardService.getOverview(),
        _dashboardService.getSales(),
        _visitService.getCurrentVisitors(),
      ]);

      state = DashboardState(
        businessReport: results[0] as BusinessReportDTO,
        salesReport: results[1] as DashboardSalesDTO,
        currentVisitors: List<CurrentVisitorResponse>.from(results[2] as List),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Greska pri ucitavanju: $e',
      );
    }
  }

  /// Refresh all data.
  Future<void> refresh() => load();
}

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(apiClientProvider));
});

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final dashboardService = ref.watch(dashboardServiceProvider);
      final visitService = ref.watch(visitServiceProvider);
      return DashboardNotifier(dashboardService, visitService);
    });
