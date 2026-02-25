import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

/// Quick actions panel with icon buttons for common operations.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Brze akcije', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: LucideIcons.logIn,
                  label: 'Check-in',
                  color: AppColors.primary,
                  onTap: () => context.go('/visitors'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionBtn(
                  icon: LucideIcons.userPlus,
                  label: 'Novi korisnik',
                  color: AppColors.secondary,
                  onTap: () => context.go('/users'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: LucideIcons.shoppingCart,
                  label: 'Kupovine',
                  color: AppColors.success,
                  onTap: () => context.go('/orders'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionBtn(
                  icon: LucideIcons.barChart3,
                  label: 'Izvjestaji',
                  color: AppColors.warning,
                  onTap: () => context.go('/reports'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _hover
                ? widget.color.withValues(alpha: 0.12)
                : AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _hover
                  ? widget.color.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTextStyles.bodySm.copyWith(
                  color: _hover ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
