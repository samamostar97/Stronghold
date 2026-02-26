import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../shared/success_animation.dart';
import '../shared/error_animation.dart';
import '../visitors/checkin_dialog.dart';

/// Inline quick-action chips for the dashboard header area.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(LucideIcons.logIn, 'Check-in', AppColors.electric, onTap: (ctx) => _openCheckIn(ctx)),
      _Action(LucideIcons.userPlus, 'Novi korisnik', AppColors.purple, route: '/users'),
      _Action(LucideIcons.shoppingCart, 'Kupovine', AppColors.success, route: '/orders'),
      _Action(LucideIcons.barChart3, 'Izvjestaji', AppColors.warning, route: '/reports'),
    ];

    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          _QuickActionChip(action: actions[i]),
        ],
      ],
    );
  }

  static Future<void> _openCheckIn(BuildContext context) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const CheckinDialog(),
    );

    if (!context.mounted) return;
    if (result == true) {
      showSuccessAnimation(context);
    } else if (result is String) {
      showErrorAnimation(context, message: result);
    }
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  final void Function(BuildContext)? onTap;
  const _Action(this.icon, this.label, this.color, {this.route, this.onTap});
}

class _QuickActionChip extends StatefulWidget {
  const _QuickActionChip({required this.action});
  final _Action action;

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          if (a.onTap != null) {
            a.onTap!(context);
          } else if (a.route != null) {
            context.go(a.route!);
          }
        },
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hover ? a.color.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: AppSpacing.buttonRadius,
            border: Border.all(
              color: _hover ? a.color.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(a.icon, size: 16, color: a.color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                a.label,
                style: AppTextStyles.label.copyWith(
                  color: _hover ? a.color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
