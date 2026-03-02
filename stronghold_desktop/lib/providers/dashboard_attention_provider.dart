import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';
import 'dashboard_provider.dart';

class DashboardAttentionState {
  final int pendingOrdersCount;
  final int expiringMembershipsCount;
  final int lowStockSupplementsCount;
  final bool isLoading;
  final String? error;

  const DashboardAttentionState({
    this.pendingOrdersCount = 0,
    this.expiringMembershipsCount = 0,
    this.lowStockSupplementsCount = 0,
    this.isLoading = false,
    this.error,
  });

  int get totalCount =>
      pendingOrdersCount + expiringMembershipsCount + lowStockSupplementsCount;

  DashboardAttentionState copyWith({
    int? pendingOrdersCount,
    int? expiringMembershipsCount,
    int? lowStockSupplementsCount,
    bool? isLoading,
    String? error,
  }) {
    return DashboardAttentionState(
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      expiringMembershipsCount:
          expiringMembershipsCount ?? this.expiringMembershipsCount,
      lowStockSupplementsCount:
          lowStockSupplementsCount ?? this.lowStockSupplementsCount,
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
          lowStockSupplementsCount: attention.lowStockSupplementsCount,
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
      final dashboardService = ref.watch(dashboardServiceProvider);
      return DashboardAttentionNotifier(dashboardService);
    });
