import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/dashboard_provider.dart';
import 'mini_bar_chart.dart';
import 'stat_card.dart';

/// KPI row of 4 stat cards with animated counters and mini charts.
class DashboardKpiRow extends StatelessWidget {
  const DashboardKpiRow({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final report = state.businessReport;
    final weekData = _weekdayData(report?.visitsByWeekday);

    final cards = [
      StatCard(
        title: 'POSJETE OVE SEDMICE',
        value: '${report?.thisWeekVisits ?? 0}',
        trendValue: report != null
            ? '${report.weekChangePct.toStringAsFixed(1)}%'
            : null,
        isPositive: (report?.weekChangePct ?? 0) >= 0,
        accentColor: AppColors.primary,
        child: MiniBarChart(
          data: weekData,
          color: AppColors.primary,
        ),
      ),
      StatCard(
        title: 'PRIHOD OVOG MJESECA',
        value: '${report?.thisMonthRevenue ?? 0} KM',
        trendValue: report != null
            ? '${report.monthChangePct.toStringAsFixed(1)}%'
            : null,
        isPositive: (report?.monthChangePct ?? 0) >= 0,
        accentColor: AppColors.success,
      ),
      StatCard(
        title: 'AKTIVNE CLANARINE',
        value: '${report?.activeMemberships ?? 0}',
        accentColor: AppColors.warning,
      ),
      StatCard(
        title: 'TRENUTNO U TERETANI',
        value: '${state.currentVisitors.length}',
        accentColor: AppColors.accent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1100) return _row(cards, 4);
        if (width >= 700) return _grid2x2(cards);
        return _column(cards);
      },
    );
  }

  List<double> _weekdayData(List<WeekdayVisitsDTO>? visits) {
    if (visits == null) return [0, 0, 0, 0, 0, 0, 0];
    const map = {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 0: 6};
    final data = List<double>.filled(7, 0);
    for (final v in visits) {
      final i = map[v.day];
      if (i != null) data[i] = v.count.toDouble();
    }
    return data;
  }

  Widget _row(List<Widget> cards, int count) {
    return Row(
      children: [
        for (int i = 0; i < count; i++) ...[
          Expanded(child: cards[i]),
          if (i < count - 1) const SizedBox(width: AppSpacing.lg),
        ],
      ],
    );
  }

  Widget _grid2x2(List<Widget> cards) {
    return Column(
      children: [
        _row([cards[0], cards[1]], 2),
        const SizedBox(height: AppSpacing.lg),
        _row([cards[2], cards[3]], 2),
      ],
    );
  }

  Widget _column(List<Widget> cards) {
    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i < cards.length - 1) const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
