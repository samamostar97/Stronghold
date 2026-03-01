import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
