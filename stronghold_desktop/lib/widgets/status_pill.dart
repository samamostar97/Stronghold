import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Tier 1 — Colored pill badge for displaying entity status.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  factory StatusPill.active() =>
      const StatusPill(label: 'Aktivan', color: AppColors.success);

  factory StatusPill.inactive() =>
      const StatusPill(label: 'Neaktivan', color: AppColors.textMuted);

  factory StatusPill.expired() =>
      const StatusPill(label: 'Istekao', color: AppColors.error);

  factory StatusPill.pending() =>
      const StatusPill(label: 'Na cekanju', color: AppColors.warning);

  factory StatusPill.paid() =>
      const StatusPill(label: 'Placeno', color: AppColors.success);

  factory StatusPill.delivered() =>
      const StatusPill(label: 'Dostavljeno', color: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.badge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
