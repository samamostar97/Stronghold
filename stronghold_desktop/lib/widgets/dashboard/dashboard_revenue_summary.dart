import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Revenue breakdown card showing today / this week / this month stats.
class DashboardRevenueSummary extends StatelessWidget {
  const DashboardRevenueSummary({super.key, this.breakdown});

  final RevenueBreakdownDTO? breakdown;

  @override
  Widget build(BuildContext context) {
    final data = breakdown;

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pregled prihoda', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xl),
          _RevenueRow(
            icon: LucideIcons.calendar,
            label: 'Danas',
            value: '${data?.todayRevenue.toStringAsFixed(2) ?? '0.00'} KM',
            subtext: '${data?.todayOrderCount ?? 0} narudzbi',
            color: AppColors.primary,
          ),
          const Divider(color: AppColors.border, height: AppSpacing.xl),
          _RevenueRow(
            icon: LucideIcons.calendarDays,
            label: 'Ova sedmica',
            value: '${data?.thisWeekRevenue.toStringAsFixed(2) ?? '0.00'} KM',
            color: AppColors.success,
          ),
          const Divider(color: AppColors.border, height: AppSpacing.xl),
          _RevenueRow(
            icon: LucideIcons.calendarRange,
            label: 'Ovaj mjesec',
            value: '${data?.thisMonthRevenue.toStringAsFixed(2) ?? '0.00'} KM',
            color: AppColors.warning,
          ),
          const Divider(color: AppColors.border, height: AppSpacing.xl),
          _RevenueRow(
            icon: LucideIcons.receipt,
            label: 'Prosjecna narudzba',
            value: '${data?.averageOrderValue.toStringAsFixed(2) ?? '0.00'} KM',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  const _RevenueRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtext,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMd),
              if (subtext != null)
                Text(subtext!, style: AppTextStyles.caption),
            ],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(color: color),
        ),
      ],
    );
  }
}
