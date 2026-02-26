import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/admin_activity_provider.dart';
import '../providers/dashboard_extras_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/dashboard/dashboard_admin_activity_feed.dart';
import '../widgets/dashboard/dashboard_checkin_heatmap.dart';
import '../widgets/dashboard/dashboard_expiring_memberships.dart';
import '../widgets/dashboard/dashboard_sales_chart.dart';
import '../widgets/dashboard/dashboard_stat_cards.dart';
import '../widgets/dashboard/dashboard_upcoming_appointments.dart';
import '../widgets/dashboard/dashboard_upcoming_seminars.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';

class DashboardHomeScreen extends ConsumerStatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  ConsumerState<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends ConsumerState<DashboardHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).load();
      ref.read(adminActivityProvider.notifier).load();
      ref.read(dashboardAppointmentsProvider.notifier).load();
      ref.read(dashboardSeminarsProvider.notifier).load();
      ref.read(dashboardExpiringMembershipsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final adminActivity = ref.watch(adminActivityProvider);
    final appointments = ref.watch(dashboardAppointmentsProvider);
    final seminars = ref.watch(dashboardSeminarsProvider);
    final expiring = ref.watch(dashboardExpiringMembershipsProvider);

    if (state.isLoading && state.businessReport == null) {
      return const ShimmerDashboard();
    }

    if (state.error != null && state.businessReport == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.error!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton.text(
              text: 'Pokusaj ponovo',
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    final report = state.businessReport;

    return SingleChildScrollView(
      padding: AppSpacing.desktopPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Stat cards
          DashboardStatCards(
            report: report,
            visitorCount: state.currentVisitors.length,
            heatmap: report?.checkInHeatmap ?? <HeatmapCellDTO>[],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ROW 2: Heatmap (full width)
          DashboardCheckinHeatmap(
            data: report?.checkInHeatmap ?? <HeatmapCellDTO>[],
          )
              .animate(delay: 500.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve),

          const SizedBox(height: AppSpacing.xl),

          // ROW 3: Sales chart (60%) + Expiring memberships (40%)
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (wide) {
                return SizedBox(
                  height: 380,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DashboardSalesChart(expand: true),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: DashboardExpiringMemberships(
                          items: expiring.items,
                          isLoading: expiring.isLoading,
                          error: expiring.error,
                          onRetry: () => ref
                              .read(
                                  dashboardExpiringMembershipsProvider.notifier)
                              .load(),
                          expand: true,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  SizedBox(height: 300, child: DashboardSalesChart(expand: true)),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 350,
                    child: DashboardExpiringMemberships(
                      items: expiring.items,
                      isLoading: expiring.isLoading,
                      error: expiring.error,
                      onRetry: () => ref
                          .read(dashboardExpiringMembershipsProvider.notifier)
                          .load(),
                      expand: true,
                    ),
                  ),
                ],
              );
            },
          )
              .animate(delay: 650.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve),

          const SizedBox(height: AppSpacing.xl),

          // ROW 4: Activity feed + Appointments + Seminars (33/33/33)
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;

              final activityFeed = DashboardAdminActivityFeed(
                items: adminActivity.items,
                isLoading: adminActivity.isLoading,
                undoInProgressIds: adminActivity.undoInProgressIds,
                error: adminActivity.error,
                onRetry: () =>
                    ref.read(adminActivityProvider.notifier).load(),
                onUndo: _buildUndoCallback(context, ref),
                expand: true,
              );

              final appointmentsWidget = DashboardUpcomingAppointments(
                items: appointments.items,
                isLoading: appointments.isLoading,
                error: appointments.error,
                onRetry: () =>
                    ref.read(dashboardAppointmentsProvider.notifier).load(),
                expand: true,
              );

              final seminarsWidget = DashboardUpcomingSeminars(
                items: seminars.items,
                isLoading: seminars.isLoading,
                error: seminars.error,
                onRetry: () =>
                    ref.read(dashboardSeminarsProvider.notifier).load(),
                expand: true,
              );

              if (wide) {
                return SizedBox(
                  height: 420,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: activityFeed),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: appointmentsWidget),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: seminarsWidget),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(height: 350, child: activityFeed),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(height: 350, child: appointmentsWidget),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(height: 350, child: seminarsWidget),
                ],
              );
            },
          )
              .animate(delay: 800.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve),
        ],
      ),
    );
  }
}

Future<void> Function(int) _buildUndoCallback(
  BuildContext context,
  WidgetRef ref,
) {
  return (id) async {
    try {
      await ref.read(adminActivityProvider.notifier).undo(id);
      if (context.mounted) {
        showSuccessAnimation(context, message: 'Undo uspjesno izvrsen.');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorAnimation(
          context,
          message:
              ErrorHandler.getContextualMessage(e, 'undo-admin-activity'),
        );
      }
    }
  };
}
