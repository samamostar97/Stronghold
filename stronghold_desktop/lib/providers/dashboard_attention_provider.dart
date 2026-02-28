import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

class DashboardAttentionState {
  final int pendingOrdersCount;
  final int expiringMembershipsCount;
  final bool isLoading;
  final String? error;

  const DashboardAttentionState({
    this.pendingOrdersCount = 0,
    this.expiringMembershipsCount = 0,
    this.isLoading = false,
    this.error,
  });

  int get totalCount => pendingOrdersCount + expiringMembershipsCount;

  DashboardAttentionState copyWith({
    int? pendingOrdersCount,
    int? expiringMembershipsCount,
    bool? isLoading,
    String? error,
  }) {
    return DashboardAttentionState(
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      expiringMembershipsCount:
          expiringMembershipsCount ?? this.expiringMembershipsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardAttentionNotifier
    extends StateNotifier<DashboardAttentionState> {
  final DashboardService _dashboardService;

  DashboardAttentionNotifier(this._dashboardService)
    : super(const DashboardAttentionState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final attention = await _dashboardService.getAttention(days: 7);

      if (mounted) {
        state = state.copyWith(
          pendingOrdersCount: attention.pendingOrdersCount,
          expiringMembershipsCount: attention.expiringMembershipsCount,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final dashboardAttentionProvider =
    StateNotifierProvider<DashboardAttentionNotifier, DashboardAttentionState>((
      ref,
    ) {
      final dashboardService = DashboardService(ref.watch(apiClientProvider));
      return DashboardAttentionNotifier(dashboardService);
    });
