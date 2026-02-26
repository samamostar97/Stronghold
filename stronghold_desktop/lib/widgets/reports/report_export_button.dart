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
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.textPrimary;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: AppTextStyles.bodyBold),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceSolid,
        foregroundColor: accent,
        disabledBackgroundColor: AppColors.surfaceSolid.withValues(alpha: 0.5),
        disabledForegroundColor: accent.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: accent.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  static const _excelGreen = Color(0xFF217346);
  static const _pdfRed = Color(0xFFB30B00);

  /// Convenience constructor for Excel export.
  static Widget excel({required VoidCallback? onPressed, String label = 'Excel'}) =>
      ReportExportButton(
        icon: LucideIcons.fileSpreadsheet,
        label: label,
        onPressed: onPressed,
        color: _excelGreen,
      );

  /// Convenience constructor for PDF export.
  static Widget pdf({required VoidCallback? onPressed, String label = 'PDF'}) =>
      ReportExportButton(
        icon: LucideIcons.fileText,
        label: label,
        onPressed: onPressed,
        color: _pdfRed,
      );
}
