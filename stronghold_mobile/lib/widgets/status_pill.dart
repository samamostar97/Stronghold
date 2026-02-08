import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}
