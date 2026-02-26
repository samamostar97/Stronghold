import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import 'report_export_button.dart';

/// A compact row with "Od" / "Do" date pickers, a clear button, and export buttons.
class ReportDateRangeBar extends StatelessWidget {
  const ReportDateRangeBar({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    required this.onExportExcel,
    required this.onExportPdf,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  static final _fmt = DateFormat('dd.MM.yyyy');

  Future<void> _pickDate(BuildContext context, DateTime? current, ValueChanged<DateTime?> onChanged) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.electric,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = dateFrom != null || dateTo != null;

    return Row(
      children: [
        ReportExportButton.excel(onPressed: onExportExcel, label: 'Export u Excel'),
        const SizedBox(width: AppSpacing.md),
        ReportExportButton.pdf(onPressed: onExportPdf, label: 'Export u PDF'),
        const SizedBox(width: AppSpacing.lg),
        _DateField(
          label: 'Od',
          value: dateFrom,
          formatter: _fmt,
          onTap: () => _pickDate(context, dateFrom, onDateFromChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            '\u2013',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ),
        _DateField(
          label: 'Do',
          value: dateTo,
          formatter: _fmt,
          onTap: () => _pickDate(context, dateTo, onDateToChanged),
        ),
        if (hasRange) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
            tooltip: 'Ponisti period',
            onPressed: () {
              onDateFromChanged(null);
              onDateToChanged(null);
            },
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(28, 28),
            ),
          ),
        ],
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.formatter,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final DateFormat formatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.calendar, size: 14, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Text(
              value != null ? '$label: ${formatter.format(value!)}' : label,
              style: AppTextStyles.bodySm.copyWith(
                color: value != null ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
