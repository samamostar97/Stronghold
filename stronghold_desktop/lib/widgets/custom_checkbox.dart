import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Tier 1 — Custom checkbox replacing Material's default.
/// Rounded square, primary border/fill when checked.
class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 20,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          border: Border.all(
            color: checked ? AppColors.primary : AppColors.textDark,
            width: 1.5,
          ),
        ),
        child: checked
            ? Icon(
                LucideIcons.check,
                size: size * 0.65,
                color: AppColors.background,
              )
            : null,
      ),
    );
  }
}
