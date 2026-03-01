import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

const chromeTabBarHeight = 42.0;

class ChromeTabBar extends StatelessWidget {
  const ChromeTabBar({super.key, required this.controller, required this.tabs});

  final TabController controller;
  final List<({IconData icon, String label})> tabs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _ChromeTab(
            icon: tabs[i].icon,
            label: tabs[i].label,
            isActive: controller.index == i,
            onTap: () => controller.animateTo(i),
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
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<_ChromeTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final background = active
        ? AppColors.primaryDim
        : (_hover ? AppColors.surfaceHover : AppColors.surface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primaryBorder : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style:
                    (active
                            ? AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                              )
                            : AppTextStyles.bodySecondary)
                        .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
