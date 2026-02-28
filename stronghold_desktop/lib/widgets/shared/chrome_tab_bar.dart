import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

const chromeTabBarHeight = 46.0;

class ChromeTabBar extends StatelessWidget {
  const ChromeTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<({IconData icon, String label})> tabs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          _ChromeTab(
            icon: tabs[i].icon,
            label: tabs[i].label,
            isActive: controller.index == i,
            onTap: () => controller.animateTo(i),
            isFirst: i == 0,
          ),
        ],
        const Spacer(),
      ],
    );
  }
}

class _ChromeTab extends StatefulWidget {
  const _ChromeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isFirst,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  State<_ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<_ChromeTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: active ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          decoration: BoxDecoration(
            color: active
                ? AppColors.surface
                : _hovered
                    ? AppColors.surfaceAlt
                    : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: active
                ? null
                : Border.all(
                    color: _hovered
                        ? AppColors.border
                        : AppColors.border.withValues(alpha: 0.5),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: active ? AppColors.electric : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      active ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
