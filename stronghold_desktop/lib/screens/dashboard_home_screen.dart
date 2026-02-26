import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/admin_activity_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/dashboard/dashboard_admin_activity_feed.dart';
import '../widgets/dashboard/dashboard_hero_header.dart';
import '../widgets/dashboard/dashboard_quick_actions.dart';
import '../widgets/dashboard/dashboard_sales_chart.dart';
import '../widgets/dashboard/dashboard_stat_cards.dart';
import '../widgets/dashboard/dashboard_today_sales.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final adminActivityState = ref.watch(adminActivityProvider);

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
          // Hero header
          const DashboardHeroHeader()
              .animate()
              .fadeIn(duration: Motion.dramatic, curve: Motion.curve)
              .scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1, 1),
                duration: Motion.dramatic,
                curve: Motion.curve,
              ),

          // Stat cards overlapping hero
          Transform.translate(
            offset: const Offset(0, -50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: DashboardStatCards(
                report: report,
                visitorCount: state.currentVisitors.length,
              ),
            ),
          ),

          // Quick actions
          const DashboardQuickActions()
              .animate(delay: 500.ms)
              .fadeIn(duration: Motion.normal, curve: Motion.curve),

          const SizedBox(height: AppSpacing.xl),

          // Main content: chart + sidebar
          _MainContent(
            report: report,
            adminActivityState: adminActivityState,
            ref: ref,
          )
              .animate(delay: 600.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ],
      ),
    );
  }
}

/// Chart + today sales + activity feed layout.
class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.report,
    required this.adminActivityState,
    required this.ref,
  });

  final BusinessReportDTO? report;
  final AdminActivityState adminActivityState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        final chart = DashboardSalesChart(
          dailySales: report?.dailySales ?? <DailySalesDTO>[],
          expand: wide,
        );

        final sidebar = _Sidebar(
          report: report,
          adminActivityState: adminActivityState,
          ref: ref,
        );

        if (wide) {
          return SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: chart),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: sidebar),
              ],
            ),
          );
        }

        return Column(
          children: [
            SizedBox(height: 300, child: chart),
            const SizedBox(height: AppSpacing.lg),
            DashboardTodaySales(breakdown: report?.revenueBreakdown),
            const SizedBox(height: AppSpacing.lg),
            DashboardAdminActivityFeed(
              items: adminActivityState.items,
              isLoading: adminActivityState.isLoading,
              undoInProgressIds: adminActivityState.undoInProgressIds,
              error: adminActivityState.error,
              onRetry: () =>
                  ref.read(adminActivityProvider.notifier).load(),
              onUndo: _buildUndoCallback(context, ref),
              expand: false,
            ),
          ],
        );
      },
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
          message: ErrorHandler.getContextualMessage(e, 'undo-admin-activity'),
        );
      }
    }
  };
}

/// Right sidebar: today sales + admin activity feed.
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.report,
    required this.adminActivityState,
    required this.ref,
  });

  final BusinessReportDTO? report;
  final AdminActivityState adminActivityState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardTodaySales(breakdown: report?.revenueBreakdown),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: DashboardAdminActivityFeed(
            items: adminActivityState.items,
            isLoading: adminActivityState.isLoading,
            undoInProgressIds: adminActivityState.undoInProgressIds,
            error: adminActivityState.error,
            onRetry: () =>
                ref.read(adminActivityProvider.notifier).load(),
            onUndo: _buildUndoCallback(context, ref),
            expand: true,
          ),
        ),
      ],
    );
  }
}
