import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Row of 4 stat cards that overlap with the hero header via Transform.translate.
class DashboardStatCards extends StatelessWidget {
  const DashboardStatCards({
    super.key,
    required this.report,
    required this.visitorCount,
  });

  final BusinessReportDTO? report;
  final int visitorCount;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData(
        icon: LucideIcons.users,
        label: 'U TERETANI',
        value: '$visitorCount',
        color: AppColors.cyan,
      ),
      _StatData(
        icon: LucideIcons.creditCard,
        label: 'PRIHOD (MJESEC)',
        value: '${(report?.thisMonthRevenue ?? 0).toStringAsFixed(0)} KM',
        trend: report != null ? _trendText(report!.monthChangePct) : null,
        isPositive: (report?.monthChangePct ?? 0) >= 0,
        color: AppColors.success,
      ),
      _StatData(
        icon: LucideIcons.activity,
        label: 'POSJETE (SEDMICA)',
        value: '${report?.thisWeekVisits ?? 0}',
        trend: report != null ? _trendText(report!.weekChangePct) : null,
        isPositive: (report?.weekChangePct ?? 0) >= 0,
        color: AppColors.electric,
      ),
      _StatData(
        icon: LucideIcons.award,
        label: 'AKTIVNE CLANARINE',
        value: '${report?.activeMemberships ?? 0}',
        color: AppColors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        if (wide) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _StatCard(data: cards[i])
                      .animate(delay: Duration(milliseconds: 150 + i * 100))
                      .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: Motion.smooth,
                        curve: Motion.curve,
                      ),
                ),
              ],
            ],
          );
        }
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (int i = 0; i < cards.length; i++)
              SizedBox(
                width: (constraints.maxWidth - AppSpacing.lg) / 2,
                child: _StatCard(data: cards[i])
                    .animate(delay: Duration(milliseconds: 150 + i * 100))
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve,
                    ),
              ),
          ],
        );
      },
    );
  }

  String _trendText(num pct) {
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool isPositive;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.isPositive = true,
    required this.color,
  });
}

class _StatCard extends StatefulWidget {
  const _StatCard({required this.data});
  final _StatData data;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: AppSpacing.cardPaddingCompact,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: _hover
                ? d.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: _hover ? AppColors.cardShadowStrong : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: d.color.withValues(alpha: 0.12),
                borderRadius: AppSpacing.avatarRadius,
              ),
              child: Icon(d.icon, color: d.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(d.label, style: AppTextStyles.overline),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(d.value, style: AppTextStyles.metricMedium),
                  ),
                  if (d.trend != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _TrendBadge(
                      value: d.trend!,
                      isPositive: d.isPositive,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.value, required this.isPositive});
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
