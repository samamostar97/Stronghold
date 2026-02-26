import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  static const _labels = ['Pregled', 'Adresa', 'Placanje', 'Potvrda'];

  const CheckoutStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: List.generate(7, (i) {
          if (i.isOdd) {
            // Connector line
            final lineIndex = i ~/ 2;
            final isCompleted = lineIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.textDark.withValues(alpha: 0.3),
              ),
            );
          }
          // Step circle
          final stepIndex = i ~/ 2;
          return _StepCircle(
            index: stepIndex,
            label: _labels[stepIndex],
            isActive: stepIndex == currentStep,
            isCompleted: stepIndex < currentStep,
          );
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Widget child;

    if (isCompleted) {
      bgColor = AppColors.success;
      borderColor = AppColors.success;
      child = const Icon(LucideIcons.check, size: 14, color: Colors.white);
    } else if (isActive) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary;
      child = Text(
        '${index + 1}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w700,
        ),
      );
    } else {
      bgColor = Colors.transparent;
      borderColor = AppColors.textDark.withValues(alpha: 0.3);
      child = Text(
        '${index + 1}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive || isCompleted
                ? Colors.white
                : AppColors.textDark,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
