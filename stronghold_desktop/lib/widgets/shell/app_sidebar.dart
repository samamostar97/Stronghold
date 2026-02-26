import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Navigation item model.
class NavItem {
  const NavItem({required this.id, required this.label, required this.icon});
  final String id;
  final String label;
  final IconData icon;
}

/// Grouped navigation items with optional section label.
class NavGroup {
  const NavGroup({this.label, required this.items});
  final String? label;
  final List<NavItem> items;
}

/// Aether sidebar — collapsible nav rail for admin shell.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.groups,
    required this.activeId,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    this.bottom,
  });

  final List<NavGroup> groups;
  final String activeId;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: collapsed ? 72 : 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _Logo(collapsed: collapsed),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                for (final group in groups) ...[
                  if (group.label != null)
                    _SectionLabel(
                        label: group.label!, collapsed: collapsed),
                  for (final item in group.items)
                    _NavTile(
                      item: item,
                      isActive: item.id == activeId,
                      collapsed: collapsed,
                      onTap: () => onSelect(item.id),
                    ),
                ],
              ],
            ),
          ),
          Container(height: 1, color: AppColors.borderLight),
          _CollapseButton(collapsed: collapsed, onTap: onToggleCollapse),
          if (bottom != null) ...[
            Container(height: 1, color: AppColors.borderLight),
            bottom!,
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.avatarRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.electric.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.avatarRadius,
        child: Image.asset('assets/images/logo.png', width: 36, height: 36),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (collapsed || constraints.maxWidth < 80) {
            return Center(child: logo);
          }
          return Row(
            children: [
              logo,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'STRONGHOLD',
                  style: AppTextStyles.sectionTitle.copyWith(
                    letterSpacing: 1.5,
                    color: AppColors.deepBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.collapsed});
  final String label;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Container(height: 1, color: AppColors.borderLight),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(
          left: 14, top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(label,
          style: AppTextStyles.overline, overflow: TextOverflow.ellipsis),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.electric.withOpacity(0.08)
                : _hover
                    ? AppColors.surfaceAlt
                    : Colors.transparent,
            borderRadius: AppSpacing.badgeRadius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  widget.collapsed || constraints.maxWidth < 80;
              return Row(
                children: [
                  if (active)
                    Container(
                      width: 3,
                      height: 20,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Icon(widget.item.icon,
                      size: 20,
                      color: active
                          ? AppColors.electric
                          : _hover
                              ? AppColors.textSecondary
                              : AppColors.textMuted),
                  if (!compact) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: active
                            ? AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.electric)
                            : AppTextStyles.bodySecondary.copyWith(
                                color: _hover
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({required this.collapsed, required this.onTap});
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: IconButton(
        icon: Icon(
          collapsed
              ? LucideIcons.panelLeftOpen
              : LucideIcons.panelLeftClose,
          size: 18,
          color: AppColors.textMuted,
        ),
        onPressed: onTap,
      ),
    );
  }
}
