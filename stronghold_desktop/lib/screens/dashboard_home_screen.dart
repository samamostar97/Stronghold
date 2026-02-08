import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/stat_card.dart';
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
            Text(
              'Greska pri ucitavanju',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Pokusaj ponovo',
              onTap: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width > 1200
            ? 40.0
            : width > 800
                ? 24.0
                : 16.0;

        return RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text('Kontrolna ploca', style: AppTypography.h2),
                const SizedBox(height: 24),

                // Row 1: KPI Stat Cards
                _buildStatCards(state, width),
                const SizedBox(height: 24),

                // Row 2: Chart + Quick Actions
                _buildMiddleRow(state, width),
                const SizedBox(height: 24),

                // Row 3: Pie chart + Recent check-ins + Bestseller
                _buildBottomRow(state, width),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROW 1: KPI STAT CARDS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatCards(DashboardState state, double width) {
    final report = state.businessReport;

    final cards = [
      StatCard(
        label: 'Posjete ove sedmice',
        value: report?.thisWeekVisits ?? 0,
        changePercent: report?.weekChangePct.toDouble(),
        changeLabel: 'vs prosle sedmice',
        icon: Icons.directions_walk,
        iconColor: AppColors.info,
      ),
      StatCard(
        label: 'Prihod ovog mjeseca',
        value: report?.thisMonthRevenue ?? 0,
        valueSuffix: 'KM',
        changePercent: report?.monthChangePct.toDouble(),
        changeLabel: 'vs proslog mjeseca',
        icon: Icons.trending_up,
        iconColor: AppColors.success,
      ),
      StatCard(
        label: 'Aktivne clanarine',
        value: report?.activeMemberships ?? 0,
        icon: Icons.card_membership,
        iconColor: AppColors.warning,
      ),
      StatCard(
        label: 'Trenutno u teretani',
        value: state.currentVisitors.length,
        icon: Icons.people,
        iconColor: AppColors.accent,
      ),
    ];

    if (width >= 1200) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 16),
          ],
        ],
      );
    }

    if (width >= 800) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i < cards.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROW 2: WEEKLY CHART + QUICK ACTIONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMiddleRow(DashboardState state, double width) {
    final chart = _WeeklyVisitsChart(
      visitsByWeekday: state.businessReport?.visitsByWeekday ?? <WeekdayVisitsDTO>[],
    );
    final actions = _QuickActionsPanel(onNavigate: widget.onNavigate);

    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: chart),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: actions),
        ],
      );
    }

    return Column(
      children: [
        chart,
        const SizedBox(height: 16),
        actions,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROW 3: PIE CHART + RECENT CHECK-INS + BESTSELLER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomRow(DashboardState state, double width) {
    final pie = _MembershipDistribution(
      report: state.membershipReport,
    );
    final checkIns = _RecentCheckIns(
      visitors: state.currentVisitors,
    );
    final bestseller = _BestsellerCard(
      bestseller: state.businessReport?.bestsellerLast30Days,
    );

    if (width >= 1200) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: pie),
          const SizedBox(width: 16),
          Expanded(child: checkIns),
          const SizedBox(width: 16),
          Expanded(child: bestseller),
        ],
      );
    }

    if (width >= 800) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: pie),
              const SizedBox(width: 16),
              Expanded(child: checkIns),
            ],
          ),
          const SizedBox(height: 16),
          bestseller,
        ],
      );
    }

    return Column(
      children: [
        pie,
        const SizedBox(height: 16),
        checkIns,
        const SizedBox(height: 16),
        bestseller,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEEKLY VISITS BAR CHART
// ═══════════════════════════════════════════════════════════════════════════

class _WeeklyVisitsChart extends StatelessWidget {
  const _WeeklyVisitsChart({required this.visitsByWeekday});

  final List<WeekdayVisitsDTO> visitsByWeekday;

  // Backend: 0=Sunday. Reorder to Mon-Sun for display.
  static const _dayLabels = ['Pon', 'Uto', 'Sri', 'Cet', 'Pet', 'Sub', 'Ned'];
  // Backend day index -> display index: Mon=1->0, Tue=2->1, ... Sat=6->5, Sun=0->6
  static const _backendToDisplay = {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 0: 6};

  @override
  Widget build(BuildContext context) {
    // Build ordered data Mon-Sun
    final data = List.filled(7, 0);
    for (final entry in visitsByWeekday) {
      final displayIdx = _backendToDisplay[entry.day];
      if (displayIdx != null) {
        data[displayIdx] = entry.count;
      }
    }

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 10.0 : (maxVal * 1.2).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sedmicna posjecenost', style: AppTypography.h3),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.panel,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_dayLabels[group.x]}: ${rod.toY.round()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max || value == meta.min) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.caption,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _dayLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _dayLabels[idx],
                            style: AppTypography.caption,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].toDouble(),
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.accent, AppColors.accentLight],
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.panel,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK ACTIONS PANEL
// ═══════════════════════════════════════════════════════════════════════════

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({this.onNavigate});

  final ValueChanged<AdminScreen>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Brze akcije', style: AppTypography.h3),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.login,
                  label: 'Check-in',
                  color: AppColors.accent,
                  onTap: () => onNavigate?.call(AdminScreen.currentVisitors),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Novi korisnik',
                  color: AppColors.info,
                  onTap: () => onNavigate?.call(AdminScreen.users),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Kupovine',
                  color: AppColors.success,
                  onTap: () => onNavigate?.call(AdminScreen.orders),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.analytics,
                  label: 'Izvjestaji',
                  color: AppColors.warning,
                  onTap: () => onNavigate?.call(AdminScreen.businessReport),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
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
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: _hover
                ? widget.color.withValues(alpha: 0.15)
                : AppColors.panel,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: _hover
                  ? widget.color.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _hover ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMBERSHIP DISTRIBUTION (DONUT CHART)
// ═══════════════════════════════════════════════════════════════════════════

class _MembershipDistribution extends StatefulWidget {
  const _MembershipDistribution({this.report});

  final MembershipPopularityReportDTO? report;

  @override
  State<_MembershipDistribution> createState() =>
      _MembershipDistributionState();
}

class _MembershipDistributionState extends State<_MembershipDistribution> {
  int _touchedIndex = -1;

  static const _colors = [
    AppColors.accent,
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = widget.report?.planStats ?? <MembershipPlanStatsDTO>[];
    final total = widget.report?.totalActiveMemberships ?? 0;

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribucija clanarina', style: AppTypography.h3),
            const SizedBox(height: 20),
            if (stats.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Nema podataka',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: [
                      for (int i = 0; i < stats.length; i++)
                        PieChartSectionData(
                          color: _colors[i % _colors.length],
                          value: stats[i].activeSubscriptions.toDouble(),
                          title: _touchedIndex == i
                              ? '${stats[i].popularityPercentage.toStringAsFixed(0)}%'
                              : '',
                          radius: _touchedIndex == i ? 40 : 32,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                  ),
                  duration: const Duration(milliseconds: 600),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              ...List.generate(stats.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stats[i].packageName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${stats[i].activeSubscriptions}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ukupno aktivnih',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RECENT CHECK-INS FEED
// ═══════════════════════════════════════════════════════════════════════════

class _RecentCheckIns extends StatelessWidget {
  const _RecentCheckIns({required this.visitors});

  final List<CurrentVisitorResponse> visitors;

  @override
  Widget build(BuildContext context) {
    // Sort by check-in time desc, take last 8
    final sorted = List<CurrentVisitorResponse>.from(visitors)
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    final recent = sorted.take(8).toList();

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nedavne prijave', style: AppTypography.h3),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Nema prijavljenih korisnika',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              )
            else
              ...List.generate(recent.length, (i) {
                final visitor = recent[i];
                final initials = _getInitials(visitor.fullName);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < recent.length - 1 ? 4 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      border: i < recent.length - 1
                          ? const Border(
                              bottom: BorderSide(
                                color: AppColors.border,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            visitor.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          visitor.checkInTimeFormatted,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BESTSELLER CARD
// ═══════════════════════════════════════════════════════════════════════════

class _BestsellerCard extends StatelessWidget {
  const _BestsellerCard({this.bestseller});

  final BestSellerDTO? bestseller;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Najprodavaniji (30 dana)', style: AppTypography.h3),
          const SizedBox(height: 20),
          if (bestseller == null)
            const SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Nema podataka',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bestseller!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prodano: ${bestseller!.quantitySold} kom',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
