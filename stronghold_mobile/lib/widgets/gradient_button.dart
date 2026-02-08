import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
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
          gradient: isLoading ? null : AppGradients.primaryGradient,
          color: isLoading ? AppColors.textDark : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (icon != null && !isLoading) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              isLoading ? 'Ucitavanje...' : label,
              style: AppTextStyles.buttonMd.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
