import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Tier 1 — KPI stat card with glass look, hover border glow, optional chart.
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.trendValue,
    this.isPositive = true,
    this.accentColor = AppColors.primary,
    this.child,
  });

  final String title;
  final String value;
  final String? trendValue;
  final bool isPositive;
  final Color accentColor;
  final Widget? child;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: _hover
                ? widget.accentColor.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.value,
                    style: AppTextStyles.statLg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.trendValue != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _TrendBadge(
                      value: widget.trendValue!,
                      isPositive: widget.isPositive,
                    ),
                  ],
                ],
              ),
            ),
            if (widget.child != null) ...[
              const SizedBox(width: AppSpacing.md),
              widget.child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.value, required this.isPositive});

  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySm.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
