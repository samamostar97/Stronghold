import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/admin_activity_provider.dart';
import '../providers/dashboard_attention_provider.dart';
import '../providers/dashboard_extras_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/dashboard/dashboard_admin_activity_feed.dart';
import '../widgets/dashboard/dashboard_visits_bar_chart.dart';
import '../widgets/dashboard/dashboard_attention_widget.dart';
import '../widgets/dashboard/dashboard_sales_chart.dart';
import '../widgets/dashboard/dashboard_stat_cards.dart';
import '../widgets/dashboard/dashboard_upcoming_appointments.dart';
import '../widgets/dashboard/dashboard_upcoming_seminars.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/visitors/checkin_dialog.dart';

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
      ref.read(dashboardAttentionProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final adminActivity = ref.watch(adminActivityProvider);
    final appointments = ref.watch(dashboardAppointmentsProvider);
    final seminars = ref.watch(dashboardSeminarsProvider);
    final attention = ref.watch(dashboardAttentionProvider);

    if (state.isOverviewLoading &&
        state.overview == null &&
        state.isSalesLoading &&
        state.salesReport == null) {
      return const ShimmerDashboard();
    }

    final overview = state.overview;

    return SingleChildScrollView(
      padding: AppSpacing.desktopPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.overviewError != null && overview == null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      state.overviewError!,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GradientButton.text(
                    text: 'Pokusaj ponovo',
                    onPressed: () =>
                        ref.read(dashboardProvider.notifier).reloadOverview(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ROW 1: Stat cards
          DashboardStatCards(
            activeMemberships: overview?.activeMemberships ?? 0,
            expiringThisWeekCount: overview?.expiringThisWeekCount ?? 0,
            todayCheckIns: overview?.todayCheckIns ?? 0,
            onQuickCheckIn: () => _openCheckIn(context, ref),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ROW 2: Trenutno u teretani | Heatmap
          LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;

                  final visitorCard = _VisitorMiniCard(
                    visitors: state.currentVisitors,
                    isLoading:
                        state.isVisitorsLoading &&
                        state.currentVisitors.isEmpty,
                    error: state.visitorsError,
                    onRetry: () =>
                        ref.read(dashboardProvider.notifier).reloadVisitors(),
                  );

                  final barChart = DashboardVisitsBarChart(
                    data: overview?.dailyVisits ?? <DailyVisitsDTO>[],
                  );

                  if (wide) {
                    const h = 320.0;
                    return SizedBox(
                      height: h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: visitorCard),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(flex: 3, child: barChart),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      visitorCard,
                      const SizedBox(height: AppSpacing.lg),
                      barChart,
                    ],
                  );
                },
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),

          const SizedBox(height: AppSpacing.xl),

          // ROW 3: Expiring memberships (40%) + Sales chart (60%)
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
                            flex: 2,
                            child: DashboardAttentionWidget(
                              state: attention,
                              onRetry: () => ref
                                  .read(dashboardAttentionProvider.notifier)
                                  .load(),
                              expand: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 3,
                            child: DashboardSalesChart(
                              expand: true,
                              data: state.salesReport,
                              isLoading:
                                  state.isSalesLoading &&
                                  state.salesReport == null,
                              error: state.salesError,
                              onRetry: () => ref
                                  .read(dashboardProvider.notifier)
                                  .reloadSales(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 350,
                        child: DashboardAttentionWidget(
                          state: attention,
                          onRetry: () => ref
                              .read(dashboardAttentionProvider.notifier)
                              .load(),
                          expand: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 300,
                        child: DashboardSalesChart(
                          expand: true,
                          data: state.salesReport,
                          isLoading:
                              state.isSalesLoading && state.salesReport == null,
                          error: state.salesError,
                          onRetry: () => ref
                              .read(dashboardProvider.notifier)
                              .reloadSales(),
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
                curve: Motion.curve,
              ),

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
                curve: Motion.curve,
              ),
        ],
      ),
    );
  }
}

Future<void> _openCheckIn(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<Object?>(
    context: context,
    builder: (_) => const CheckinDialog(),
  );

  if (result == true && context.mounted) {
    showSuccessAnimation(context);
    ref.read(dashboardProvider.notifier).refresh();
  } else if (result is String && context.mounted) {
    showErrorAnimation(context, message: result);
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Mini stat card for dashboard ROW 2
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _VisitorMiniCard extends StatefulWidget {
  const _VisitorMiniCard({
    required this.visitors,
    required this.isLoading,
    required this.onRetry,
    this.error,
  });

  final List<CurrentVisitorResponse> visitors;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  State<_VisitorMiniCard> createState() => _VisitorMiniCardState();
}

class _VisitorMiniCardState extends State<_VisitorMiniCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _borderColor;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _borderColor = ColorTween(
      begin: AppColors.purple.withValues(alpha: 0.5),
      end: AppColors.orange.withValues(alpha: 0.45),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/visitors'),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedBuilder(
          animation: _borderColor,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(
                  color: _borderColor.value ?? AppColors.border,
                  width: 1.5,
                ),
                boxShadow: _hover
                    ? AppColors.cardShadowStrong
                    : AppColors.cardShadow,
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon (empty only) + title + live dot
                Row(
                  children: [
                    if (widget.isLoading || widget.visitors.isEmpty) ...[
                      Icon(LucideIcons.users, size: 18, color: AppColors.cyan),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text('Trenutno u teretani', style: AppTextStyles.headingSm),
                    const Spacer(),
                    const _LiveDot(),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Content
                Expanded(
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.cyan,
                            ),
                          ),
                        )
                      : widget.error != null && widget.visitors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.error!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GradientButton.text(
                                text: 'Pokusaj ponovo',
                                onPressed: widget.onRetry,
                              ),
                            ],
                          ),
                        )
                      : widget.visitors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _SleepAnimation(),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Niko trenutno nije prijavljen',
                                style: AppTextStyles.bodyBold,
                              ),
                            ],
                          ),
                        )
                      : _VisitorList(visitors: widget.visitors),
                ),
                const SizedBox(height: AppSpacing.md),
                // Bottom: nav description + arrow button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.buttonRadius,
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pogledaj sve',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.cyan,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          LucideIcons.arrowRight,
                          size: 14,
                          color: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Visitor list â€” shows visitors that fit, "+N more" if overflow
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _VisitorList extends StatelessWidget {
  const _VisitorList({required this.visitors});
  final List<CurrentVisitorResponse> visitors;

  String _initials(CurrentVisitorResponse v) {
    final f = v.firstName.isNotEmpty ? v.firstName[0] : '';
    final l = v.lastName.isNotEmpty ? v.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String _duration(DateTime checkIn) {
    final diff = DateTime.now().difference(checkIn);
    if (diff.inMinutes < 1) return 'upravo';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rowHeight = 40.0;
        const gap = 6.0;
        final maxVisible = ((constraints.maxHeight + gap) / (rowHeight + gap))
            .floor();
        final remaining = visitors.length - maxVisible;
        // If we need a "+N" row, show one less visitor
        final showCount = remaining > 0
            ? (maxVisible - 1).clamp(0, visitors.length)
            : visitors.length;
        final extraCount = visitors.length - showCount;

        return Column(
          children: [
            for (int i = 0; i < showCount; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              SizedBox(
                height: rowHeight,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(visitors[i]),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${visitors[i].firstName} ${visitors[i].lastName}',
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _duration(visitors[i].checkInTime),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (extraCount > 0) ...[
              const SizedBox(height: gap),
              SizedBox(
                height: rowHeight,
                child: Center(
                  child: Text(
                    '+ jos $extraCount',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Sleep animation â€” three Z's floating up with stagger
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SleepAnimation extends StatefulWidget {
  const _SleepAnimation();

  @override
  State<_SleepAnimation> createState() => _SleepAnimationState();
}

class _SleepAnimationState extends State<_SleepAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const zees = [
      (delay: 0.0, size: 14.0, dx: 0.0),
      (delay: 0.2, size: 18.0, dx: 10.0),
      (delay: 0.4, size: 22.0, dx: 20.0),
    ];

    return SizedBox(
      width: 60,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [for (final z in zees) _buildZ(z.delay, z.size, z.dx)],
          );
        },
      ),
    );
  }

  Widget _buildZ(double delay, double size, double dx) {
    final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
    // Fade in 0â†’0.3, hold 0.3â†’0.6, fade out 0.6â†’1.0
    final opacity = t < 0.3
        ? (t / 0.3)
        : t < 0.6
        ? 1.0
        : 1.0 - ((t - 0.6) / 0.4);
    final yOffset = -30.0 * t;

    return Positioned(
      left: 10 + dx,
      bottom: 0,
      child: Transform.translate(
        offset: Offset(0, yOffset),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Text(
            'z',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: AppColors.cyan.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Live dot (blinking indicator)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.cyan,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

