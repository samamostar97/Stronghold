import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Tappable field that opens a date (and optionally time) picker.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.includeTime = false,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool includeTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _pick(BuildContext context) async {
    final theme = _pickerTheme(context);
    final minDate = firstDate ?? DateTime(2020);
    final maxDate = lastDate ?? DateTime(2035);
    var initialDate = value ?? DateTime.now();
    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    } else if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (ctx, child) => Theme(data: theme, child: child!),
    );
    if (date == null || !context.mounted) return;

    if (!includeTime) {
      onChanged(date);
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: value != null
          ? TimeOfDay.fromDateTime(value!)
          : TimeOfDay.now(),
      builder: (ctx, child) => Theme(data: theme, child: child!),
    );
    if (time == null) return;
    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  ThemeData _pickerTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        surface: AppColors.surfaceSolid,
        onSurface: AppColors.textPrimary,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceSolid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Odaberi...'
        : includeTime
            ? DateFormat('dd.MM.yyyy  HH:mm').format(value!)
            : DateFormat('dd.MM.yyyy').format(value!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceSolid,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMd.copyWith(
                        color: value == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(LucideIcons.calendar,
                    color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
