import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class NavItem {
  const NavItem({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

class NavGroup {
  const NavGroup({this.label, required this.items});

  final String? label;
  final List<NavItem> items;
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.groups,
    required this.activeId,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    required this.onLogout,
  });

  final List<NavGroup> groups;
  final String activeId;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: collapsed ? 84 : 252,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BrandHeader(collapsed: collapsed),
            const Divider(height: 1, color: AppColors.borderLight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                children: [
                  for (final group in groups) ...[
                    if (group.label != null)
                      _GroupLabel(label: group.label!, collapsed: collapsed),
                    for (final item in group.items)
                      _NavTile(
                        item: item,
                        collapsed: collapsed,
                        active: item.id == activeId,
                        onTap: () => onSelect(item.id),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _SidebarAction(
                      icon: collapsed
                          ? LucideIcons.panelLeftOpen
                          : LucideIcons.panelLeftClose,
                      label: collapsed ? 'Expand' : 'Collapse',
                      collapsed: collapsed,
                      onTap: onToggleCollapse,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SidebarAction(
                      icon: LucideIcons.logOut,
                      label: 'Logout',
                      collapsed: collapsed,
                      onTap: onLogout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: AppSpacing.avatarRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: AppSpacing.avatarRadius,
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stronghold',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Admin Console',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label, required this.collapsed});

  final String label;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Divider(height: 1, color: AppColors.borderLight),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Text(label.toUpperCase(), style: AppTextStyles.overline),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.collapsed,
    required this.active,
    required this.onTap,
  });

  final NavItem item;
  final bool collapsed;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final background = active
        ? AppColors.primaryDim
        : (_hover ? AppColors.surfaceHover : Colors.transparent);

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(
          color: active
              ? AppColors.primaryBorder
              : (_hover ? AppColors.borderHover : Colors.transparent),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: Icon(
              widget.item.icon,
              size: 16,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.item.label,
                style: active
                    ? AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      )
                    : AppTextStyles.bodySecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.collapsed ? widget.item.label : '',
        waitDuration: const Duration(milliseconds: 500),
        child: GestureDetector(onTap: widget.onTap, child: tile),
      ),
    );
  }
}

class _SidebarAction extends StatefulWidget {
  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarAction> createState() => _SidebarActionState();
}

class _SidebarActionState extends State<_SidebarAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? AppColors.surfaceHover : Colors.transparent,
            borderRadius: AppSpacing.smallRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 14, color: AppColors.textSecondary),
              if (!widget.collapsed) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
