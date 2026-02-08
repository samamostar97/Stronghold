import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

/// Colored pill badge for displaying entity status.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  /// Green "Aktivan" pill
  factory StatusPill.active() =>
      const StatusPill(label: 'Aktivan', color: AppColors.success);

  /// Muted "Neaktivan" pill
  factory StatusPill.inactive() =>
      const StatusPill(label: 'Neaktivan', color: AppColors.muted);

  /// Red "Istekao" pill
  factory StatusPill.expired() =>
      const StatusPill(label: 'Istekao', color: AppColors.accent);

  /// Amber "Na cekanju" pill
  factory StatusPill.pending() =>
      const StatusPill(label: 'Na cekanju', color: AppColors.warning);

  /// Green "Placeno" pill
  factory StatusPill.paid() =>
      const StatusPill(label: 'Placeno', color: AppColors.success);

  /// Blue "Dostavljeno" pill
  factory StatusPill.delivered() =>
      const StatusPill(label: 'Dostavljeno', color: AppColors.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
