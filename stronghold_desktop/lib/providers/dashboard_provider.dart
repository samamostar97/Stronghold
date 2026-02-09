import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Aggregated dashboard state composing data from multiple services.
class DashboardState {
  final BusinessReportDTO? businessReport;
  final MembershipPopularityReportDTO? membershipReport;
  final List<CurrentVisitorResponse> currentVisitors;
  final List<ActivityFeedItemDTO> activityFeed;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.businessReport,
    this.membershipReport,
    this.currentVisitors = const [],
    this.activityFeed = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    BusinessReportDTO? businessReport,
    MembershipPopularityReportDTO? membershipReport,
    List<CurrentVisitorResponse>? currentVisitors,
    List<ActivityFeedItemDTO>? activityFeed,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      businessReport: businessReport ?? this.businessReport,
      membershipReport: membershipReport ?? this.membershipReport,
      currentVisitors: currentVisitors ?? this.currentVisitors,
      activityFeed: activityFeed ?? this.activityFeed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Dashboard notifier that fetches data from existing services in parallel.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ReportsService _reportsService;
  final VisitService _visitService;

  DashboardNotifier(this._reportsService, this._visitService)
      : super(const DashboardState());

  /// Load all dashboard data in parallel.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _reportsService.getBusinessReport(),
        _reportsService.getMembershipPopularityReport(),
        _visitService.getCurrentVisitors(),
        _reportsService.getActivityFeed(),
      ]);

      state = DashboardState(
        businessReport: results[0] as BusinessReportDTO,
        membershipReport: results[1] as MembershipPopularityReportDTO,
        currentVisitors: List<CurrentVisitorResponse>.from(results[2] as List),
        activityFeed: results[3] as List<ActivityFeedItemDTO>,
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

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final reportsService = ReportsService(ref.watch(apiClientProvider));
  final visitService = VisitService(ref.watch(apiClientProvider));
  return DashboardNotifier(reportsService, visitService);
});
