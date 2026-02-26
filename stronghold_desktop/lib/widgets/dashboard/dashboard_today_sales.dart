import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Compact card showing today's and this week's revenue.
class DashboardTodaySales extends StatelessWidget {
  const DashboardTodaySales({super.key, required this.breakdown});

  final RevenueBreakdownDTO? breakdown;

  @override
  Widget build(BuildContext context) {
    final revenue = breakdown?.todayRevenue ?? 0;
    final orders = breakdown?.todayOrderCount ?? 0;
    final weekRevenue = breakdown?.thisWeekRevenue ?? 0;

    return GlassCard(
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
                  borderRadius: AppSpacing.avatarRadius,
                ),
                child: const Icon(
                  LucideIcons.banknote,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Prodaja danas', style: AppTextStyles.cardTitle),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${revenue.toStringAsFixed(2)} KM',
                        style: AppTextStyles.metricMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    Text('$orders narudzbi', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.electric.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.chipRadius,
                ),
                child: Text(
                  'Sedmica: ${weekRevenue.toStringAsFixed(0)} KM',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.electric,
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
