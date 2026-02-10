import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../screens/appointment_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/nutritionist_list_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/review_history_screen.dart';
import '../screens/seminar_screen.dart';
import '../screens/trainer_list_screen.dart';
import '../screens/user_progress_screen.dart';
import 'glass_card.dart';

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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.screen),
                    ),
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
  final Widget screen;

  const _ExploreItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.screen,
  });
}

const _items = <_ExploreItem>[
  _ExploreItem(
    icon: LucideIcons.trendingUp,
    color: AppColors.primary,
    title: 'Moj Napredak',
    hint: 'Level, XP, statistika',
    screen: UserProgressScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.calendar,
    color: AppColors.secondary,
    title: 'Termini',
    hint: 'Raspored i rezervacije',
    screen: AppointmentScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.trophy,
    color: AppColors.warning,
    title: 'Hall of Fame',
    hint: 'Rang lista clanova',
    screen: LeaderboardScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.dumbbell,
    color: AppColors.success,
    title: 'Treneri',
    hint: 'Pregled trenera',
    screen: TrainerListScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.apple,
    color: AppColors.accent,
    title: 'Nutricionisti',
    hint: 'Savjeti za ishranu',
    screen: NutritionistListScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.graduationCap,
    color: AppColors.orange,
    title: 'Seminari',
    hint: 'Edukacije i radionice',
    screen: SeminarScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.package,
    color: AppColors.primary,
    title: 'Narudzbe',
    hint: 'Historija narudzbi',
    screen: OrderHistoryScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.shoppingCart,
    color: AppColors.error,
    title: 'Korpa',
    hint: 'Trenutna korpa',
    screen: CartScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.star,
    color: AppColors.warning,
    title: 'Recenzije',
    hint: 'Moje recenzije',
    screen: ReviewHistoryScreen(),
  ),
  _ExploreItem(
    icon: LucideIcons.helpCircle,
    color: AppColors.textMuted,
    title: 'FAQ',
    hint: 'Cesta pitanja',
    screen: FaqScreen(),
  ),
];
