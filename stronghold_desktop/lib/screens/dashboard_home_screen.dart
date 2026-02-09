import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../widgets/dashboard_activity_feed.dart';
import '../widgets/dashboard_sales_chart.dart';
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

    final report = state.businessReport;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
        final wide = w >= 900;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick actions + gym occupancy
              _QuickActionsBar(
                onNavigate: widget.onNavigate,
                visitorCount: state.currentVisitors.length,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Main: sales chart + right sidebar (today sales + activity)
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DashboardSalesChart(
                              dailySales: report?.dailySales ?? [],
                              expand: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _TodaySalesCard(
                                  breakdown: report?.revenueBreakdown,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Expanded(
                                  child: DashboardActivityFeed(
                                    items: state.activityFeed,
                                    expand: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DashboardSalesChart(
                              dailySales: report?.dailySales ?? [],
                              expand: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _TodaySalesCard(
                            breakdown: report?.revenueBreakdown,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Expanded(
                            child: DashboardActivityFeed(
                              items: state.activityFeed,
                              expand: true,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Quick actions bar ───────────────────────────────────────────────────

class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar({
    required this.onNavigate,
    required this.visitorCount,
  });

  final ValueChanged<AdminScreen>? onNavigate;
  final int visitorCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final actions = [
          _ActionCard(
            icon: LucideIcons.logIn,
            label: 'Check-in',
            color: AppColors.primary,
            onTap: () => onNavigate?.call(AdminScreen.currentVisitors),
          ),
          _ActionCard(
            icon: LucideIcons.userPlus,
            label: 'Novi korisnik',
            color: AppColors.secondary,
            onTap: () => onNavigate?.call(AdminScreen.users),
          ),
          _ActionCard(
            icon: LucideIcons.shoppingCart,
            label: 'Kupovine',
            color: AppColors.success,
            onTap: () => onNavigate?.call(AdminScreen.orders),
          ),
        ];
        final gym = _GymOccupancyCard(
          count: visitorCount,
          onTap: () => onNavigate?.call(AdminScreen.currentVisitors),
        );

        if (wide) {
          return Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                Expanded(child: actions[i]),
                const SizedBox(width: AppSpacing.lg),
              ],
              Expanded(child: gym),
            ],
          );
        }
        return Column(
          children: [
            Row(children: [
              Expanded(child: actions[0]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: actions[1]),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(child: actions[2]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: gym),
            ]),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: _hover
                  ? widget.color.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.08),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: _hover
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GymOccupancyCard extends StatefulWidget {
  const _GymOccupancyCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  State<_GymOccupancyCard> createState() => _GymOccupancyCardState();
}

class _GymOccupancyCardState extends State<_GymOccupancyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: _hover
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child:
                    Icon(LucideIcons.users, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.count}',
                      style: AppTextStyles.stat.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      'u teretani',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySalesCard extends StatelessWidget {
  const _TodaySalesCard({required this.breakdown});

  final RevenueBreakdownDTO? breakdown;

  @override
  Widget build(BuildContext context) {
    final revenue = breakdown?.todayRevenue ?? 0;
    final orders = breakdown?.todayOrderCount ?? 0;
    final weekRevenue = breakdown?.thisWeekRevenue ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(LucideIcons.banknote,
                    color: AppColors.success, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child:
                    Text('Prodaja danas', style: AppTextStyles.headingSm),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${revenue.toStringAsFixed(2)} KM',
                      style: AppTextStyles.stat.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text('$orders narudzbi', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'Sedmica: ${weekRevenue.toStringAsFixed(0)} KM',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
