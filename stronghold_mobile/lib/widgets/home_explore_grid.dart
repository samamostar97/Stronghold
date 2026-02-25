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
        Text('Istrazi', style: AppTextStyles.headingSm),
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
                    hint: item.hint,
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
  final String hint;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.bodyBold,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            maxLines: 1,
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
  final String hint;
  final String path;

  const _ExploreItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.path,
  });
}

const _items = <_ExploreItem>[
  _ExploreItem(
    icon: LucideIcons.trendingUp,
    color: AppColors.primary,
    title: 'Moj Napredak',
    hint: 'Level, XP, statistika',
    path: '/progress',
  ),
  _ExploreItem(
    icon: LucideIcons.calendar,
    color: AppColors.secondary,
    title: 'Termini',
    hint: 'Raspored i rezervacije',
    path: '/appointments',
  ),
  _ExploreItem(
    icon: LucideIcons.trophy,
    color: AppColors.warning,
    title: 'Hall of Fame',
    hint: 'Rang lista clanova',
    path: '/leaderboard',
  ),
  _ExploreItem(
    icon: LucideIcons.dumbbell,
    color: AppColors.success,
    title: 'Treneri',
    hint: 'Pregled trenera',
    path: '/trainers',
  ),
  _ExploreItem(
    icon: LucideIcons.apple,
    color: AppColors.accent,
    title: 'Nutricionisti',
    hint: 'Savjeti za ishranu',
    path: '/nutritionists',
  ),
  _ExploreItem(
    icon: LucideIcons.graduationCap,
    color: AppColors.orange,
    title: 'Seminari',
    hint: 'Edukacije i radionice',
    path: '/seminars',
  ),
  _ExploreItem(
    icon: LucideIcons.package,
    color: AppColors.primary,
    title: 'Narudzbe',
    hint: 'Historija narudzbi',
    path: '/orders',
  ),
  _ExploreItem(
    icon: LucideIcons.shoppingCart,
    color: AppColors.error,
    title: 'Korpa',
    hint: 'Trenutna korpa',
    path: '/cart',
  ),
  _ExploreItem(
    icon: LucideIcons.star,
    color: AppColors.warning,
    title: 'Recenzije',
    hint: 'Moje recenzije',
    path: '/reviews',
  ),
  _ExploreItem(
    icon: LucideIcons.helpCircle,
    color: AppColors.textMuted,
    title: 'FAQ',
    hint: 'Cesta pitanja',
    path: '/faq',
  ),
];
