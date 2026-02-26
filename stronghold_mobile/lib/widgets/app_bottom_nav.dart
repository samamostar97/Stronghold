import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: LucideIcons.home, label: 'Pocetna'),
    _NavItem(icon: LucideIcons.shoppingBag, label: 'Prodavnica'),
    _NavItem(icon: LucideIcons.user, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.electric.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active indicator bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: active ? 20 : 0,
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        decoration: BoxDecoration(
                          gradient: active
                              ? AppColors.accentGradient
                              : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        item.icon,
                        size: 22,
                        color: active
                            ? AppColors.electric
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.label,
                        style: (active
                                ? AppTextStyles.tabActive
                                : AppTextStyles.tabInactive)
                            .copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
