import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<int> hours;
  final int? selectedHour;
  final ValueChanged<int> onHourSelected;

  const TimeSlotGrid({
    super.key,
    required this.hours,
    this.selectedHour,
    required this.onHourSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            'Nema dostupnih termina za ovaj datum',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: hours.map((hour) {
        final active = selectedHour == hour;
        return GestureDetector(
          onTap: () => onHourSelected(hour),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.primaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.primaryBorder,
              ),
            ),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTextStyles.bodyBold.copyWith(
                color: active ? AppColors.background : AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
