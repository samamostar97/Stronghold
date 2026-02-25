import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Reusable export button for report tabs (Excel / PDF).
class ReportExportButton extends StatelessWidget {
  const ReportExportButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: AppTextStyles.bodyBold),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceSolid,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.surfaceSolid.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  /// Convenience constructor for Excel export.
  static Widget excel({required VoidCallback? onPressed}) =>
      ReportExportButton(
        icon: LucideIcons.fileSpreadsheet,
        label: 'Excel',
        onPressed: onPressed,
      );

  /// Convenience constructor for PDF export.
  static Widget pdf({required VoidCallback? onPressed}) => ReportExportButton(
        icon: LucideIcons.fileText,
        label: 'PDF',
        onPressed: onPressed,
      );
}
