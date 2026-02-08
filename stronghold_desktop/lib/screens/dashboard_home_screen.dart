import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_activity_panel.dart';
import '../widgets/dashboard_bestseller_card.dart';
import '../widgets/dashboard_kpi_row.dart';
import '../widgets/dashboard_membership_panel.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_recent_members.dart';
import '../widgets/gradient_button.dart';
import '../widgets/shimmer_loading.dart';
import 'admin_dashboard_screen.dart';

class DashboardHomeScreen extends ConsumerStatefulWidget {
  const DashboardHomeScreen({super.key, this.onNavigate});

  final ValueChanged<AdminScreen>? onNavigate;

  @override
  ConsumerState<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends ConsumerState<DashboardHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    if (state.isLoading && state.businessReport == null) {
      return const ShimmerDashboard();
    }

    if (state.error != null && state.businessReport == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
            const SizedBox(height: AppSpacing.sm),
            Text(state.error!, style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              text: 'Pokusaj ponovo',
              onTap: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    final visits = state.businessReport?.visitsByWeekday ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
        final wide = w >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardKpiRow(state: state),
              const SizedBox(height: AppSpacing.xxl),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: DashboardActivityPanel(
                        visitsByWeekday: visits)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: DashboardQuickActions(
                        onNavigate: widget.onNavigate)),
                  ],
                )
              else ...[
                DashboardActivityPanel(visitsByWeekday: visits),
                const SizedBox(height: AppSpacing.lg),
                DashboardQuickActions(onNavigate: widget.onNavigate),
              ],
              const SizedBox(height: AppSpacing.xxl),
              if (w >= 1200)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: DashboardMembershipPanel(
                        report: state.membershipReport)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: DashboardRecentMembers(
                        visitors: state.currentVisitors)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: DashboardBestsellerCard(
                        bestseller: state.businessReport?.bestsellerLast30Days)),
                  ],
                )
              else if (w >= 800)
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: DashboardMembershipPanel(
                          report: state.membershipReport)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: DashboardRecentMembers(
                          visitors: state.currentVisitors)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DashboardBestsellerCard(
                      bestseller: state.businessReport?.bestsellerLast30Days),
                ])
              else ...[
                DashboardMembershipPanel(report: state.membershipReport),
                const SizedBox(height: AppSpacing.lg),
                DashboardRecentMembers(visitors: state.currentVisitors),
                const SizedBox(height: AppSpacing.lg),
                DashboardBestsellerCard(
                    bestseller: state.businessReport?.bestsellerLast30Days),
              ],
            ],
          ),
        );
      },
    );
  }
}
