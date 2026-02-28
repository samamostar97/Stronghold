import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../shared/stat_card.dart';

/// KPI row of 4 stat cards with animated counters and mini charts.
class DashboardKpiRow extends StatelessWidget {
  const DashboardKpiRow({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final overview = state.overview;

    final cards = [
      StatCard(
        title: 'POSJETE DANAS',
        value: '${overview?.todayCheckIns ?? 0}',
        accentColor: AppColors.success,
      ),
      StatCard(
        title: 'AKTIVNE CLANARINE',
        value: '${overview?.activeMemberships ?? 0}',
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
        if (width >= 900) return _row(cards, 3);
        if (width >= 600) {
          return Column(
            children: [
              _row([cards[0], cards[1]], 2),
              const SizedBox(height: AppSpacing.lg),
              cards[2],
            ],
          );
        }
        return _column(cards);
      },
    );
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
