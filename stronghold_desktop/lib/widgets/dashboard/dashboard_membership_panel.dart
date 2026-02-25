import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Membership breakdown panel with ring progress and plan bars.
class DashboardMembershipPanel extends StatelessWidget {
  const DashboardMembershipPanel({super.key, this.report});

  final MembershipPopularityReportDTO? report;

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.accent,
    AppColors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final stats = report?.planStats ?? <MembershipPlanStatsDTO>[];
    final total = report?.totalActiveMemberships ?? 0;
    final topPct = stats.isNotEmpty ? stats.first.popularityPercentage : 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Distribucija clanarina', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xl),
          if (stats.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text('Nema podataka', style: AppTextStyles.bodyMd),
              ),
            )
          else ...[
            Center(
              child: RingProgress(
                percentage: topPct.toDouble(),
                color: _colors[0],
                size: 80,
                strokeWidth: 6,
                child: Text(
                  '${topPct.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyBold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (int i = 0; i < stats.length; i++) ...[
              _PlanRow(
                name: stats[i].packageName,
                count: stats[i].activeSubscriptions,
                pct: stats[i].popularityPercentage.toDouble(),
                color: _colors[i % _colors.length],
              ),
              if (i < stats.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ukupno aktivnih', style: AppTextStyles.bodySm),
                  Text('$total', style: AppTextStyles.bodyBold),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.name,
    required this.count,
    required this.pct,
    required this.color,
  });

  final String name;
  final int count;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(name, style: AppTextStyles.bodySm,
              overflow: TextOverflow.ellipsis),
        ),
        Text('$count', style: AppTextStyles.bodyBold),
      ],
    );
  }
}
