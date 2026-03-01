import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class ScreenIntroBanner extends StatelessWidget {
  const ScreenIntroBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.panelRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 860;

          final leading = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.sectionTitle),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ],
          );

          if (narrow || trailing == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                if (trailing != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  trailing!,
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: leading),
              const SizedBox(width: AppSpacing.lg),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
