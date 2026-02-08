import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;
  final bool fullWidth;

  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: fullWidth ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: c),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: c),
              ),
              const SizedBox(width: AppSpacing.sm),
            ] else if (icon != null) ...[
              Icon(icon, size: 18, color: c),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              isLoading ? 'Ucitavanje...' : label,
              style: AppTextStyles.buttonMd.copyWith(color: c),
            ),
          ],
        ),
      ),
    );
  }
}
