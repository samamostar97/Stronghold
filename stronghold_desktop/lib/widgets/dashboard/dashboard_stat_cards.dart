import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Row of stat cards with rich content.
class DashboardStatCards extends StatelessWidget {
  const DashboardStatCards({
    super.key,
    required this.activeMemberships,
    required this.expiringThisWeekCount,
    required this.todayCheckIns,
    required this.onQuickCheckIn,
  });

  final int activeMemberships;
  final int expiringThisWeekCount;
  final int todayCheckIns;
  final VoidCallback onQuickCheckIn;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      // 1. BRZI CHECK-IN
      _QuickCheckInCard(onTap: onQuickCheckIn),

      // 2. AKTIVNE CLANARINE
      _StatCardShell(
        color: AppColors.purple,
        icon: LucideIcons.award,
        child: _CardContent(
          label: 'AKTIVNE CLANARINE',
          value: '$activeMemberships',
          color: AppColors.purple,
          warning: expiringThisWeekCount > 0
              ? '$expiringThisWeekCount isticu ove sedmice'
              : null,
        ),
      ),

      // 3. POSJETE DANAS
      _StatCardShell(
        color: AppColors.electric,
        icon: LucideIcons.footprints,
        child: _CardContent(
          label: 'POSJETE DANAS',
          value: '$todayCheckIns',
          color: AppColors.electric,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        if (wide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: cards[i]
                        .animate(delay: Duration(milliseconds: 150 + i * 100))
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                  ),
                ],
              ],
            ),
          );
        }
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (int i = 0; i < cards.length; i++)
              SizedBox(
                width: (constraints.maxWidth - AppSpacing.lg) / 2,
                child: cards[i]
                    .animate(delay: Duration(milliseconds: 150 + i * 100))
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve,
                    ),
              ),
          ],
        );
      },
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK CHECK-IN CARD
// ─────────────────────────────────────────────────────────────────────────────

class _QuickCheckInCard extends StatelessWidget {
  const _QuickCheckInCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _StatCardShell(
        color: AppColors.success,
        icon: LucideIcons.logIn,
        child: _CardContent(
          label: 'BRZI CHECK-IN',
          value: 'Check-in',
          color: AppColors.success,
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: AppSpacing.badgeRadius,
            ),
            child: Icon(
              LucideIcons.arrowRight,
              size: 14,
              color: AppColors.success,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD SHELL (hover, border, shadow)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardShell extends StatefulWidget {
  const _StatCardShell({
    required this.color,
    required this.icon,
    required this.child,
  });

  final Color color;
  final IconData icon;
  final Widget child;

  @override
  State<_StatCardShell> createState() => _StatCardShellState();
}

class _StatCardShellState extends State<_StatCardShell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: AppSpacing.cardPaddingCompact,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: _hover
                ? widget.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow:
              _hover ? AppColors.cardShadowStrong : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: AppSpacing.avatarRadius,
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.label,
    required this.value,
    required this.color,
    this.warning,
    this.trailing,
  });

  final String label;
  final String value;
  final Color color;
  final String? warning;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: AppTextStyles.metricMedium),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
        if (warning != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle,
                  size: 12, color: AppColors.orange),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  warning!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.orange, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
