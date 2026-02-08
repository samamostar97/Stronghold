import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Tier 1 — Gradient avatar square with initials.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 36,
    this.color,
  });

  final String initials;
  final double size;
  final Color? color;

  /// Derive a consistent color from the initials string.
  Color get _derivedColor {
    if (color != null) return color!;
    const palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.accent,
      AppColors.orange,
    ];
    final hash = initials.codeUnits.fold<int>(0, (h, c) => h + c);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final c = _derivedColor;
    final fontSize = size * 0.38;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withValues(alpha: 0.40),
            c.withValues(alpha: 0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: AppTextStyles.bodyBold.copyWith(
          color: c,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
