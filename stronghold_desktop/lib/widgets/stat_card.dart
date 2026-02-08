import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

/// Animated KPI stat card with count-up animation and change badge.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueSuffix,
    this.changePercent,
    this.changeLabel,
    this.icon,
    this.iconColor,
  });

  final String label;
  final num value;
  final String? valueSuffix;
  final num? changePercent;
  final String? changeLabel;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.accent;

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardBorder,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.cardShadow,
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.large - 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          if (icon != null) const SizedBox(height: 16),
          Text(
            label,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<num>(
            tween: Tween<num>(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              final formatted = _formatValue(animValue);
              return Text(
                valueSuffix != null ? '$formatted $valueSuffix' : formatted,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
          if (changePercent != null || changeLabel != null) ...[
            const SizedBox(height: 8),
            _ChangeBadge(
              changePercent: changePercent,
              changeLabel: changeLabel,
            ),
          ],
        ],
      ),
      ),
    );
  }

  String _formatValue(num val) {
    if (value is int || value == value.roundToDouble()) {
      return val.round().toString();
    }
    return val.toStringAsFixed(2);
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({this.changePercent, this.changeLabel});

  final num? changePercent;
  final String? changeLabel;

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent != null && changePercent! >= 0;
    final badgeColor = changePercent == null
        ? AppColors.muted
        : isPositive
            ? AppColors.success
            : AppColors.accent;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        if (changePercent != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: badgeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${changePercent!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        if (changeLabel != null)
          Text(
            changeLabel!,
            style: AppTypography.caption,
          ),
      ],
    );
  }
}
