import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class HomeExploreGrid extends StatelessWidget {
  const HomeExploreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Istrazi',
            style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = AppSpacing.sm;
            final cardWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _items.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: _ExploreCard(
                    icon: item.icon,
                    color: item.color,
                    title: item.title,
                    onTap: () => context.push(item.path),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      backgroundColor: const Color(0x33FFFFFF),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                  color: AppColors.navyBlue.withValues(alpha: 0.5),
                  width: 0.5),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExploreItem {
  final IconData icon;
  final Color color;
  final String title;
  final String path;

  const _ExploreItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.path,
  });
}

const _items = <_ExploreItem>[
  _ExploreItem(
    icon: LucideIcons.graduationCap,
    color: AppColors.orange,
    title: 'Seminari',
    path: '/seminars',
  ),
];
