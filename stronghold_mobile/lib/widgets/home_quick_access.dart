import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../screens/appointment_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/membership_history_screen.dart';
import '../screens/nutritionist_list_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/review_history_screen.dart';
import '../screens/seminar_screen.dart';
import '../screens/supplement_shop_screen.dart';
import '../screens/trainer_list_screen.dart';
import '../screens/user_progress_screen.dart';
import 'section_header.dart';

class HomeQuickAccess extends StatelessWidget {
  const HomeQuickAccess({super.key});

  static const _items = [
    _QAItem(LucideIcons.trendingUp, 'Personalni napredak'),
    _QAItem(LucideIcons.trophy, 'Hall of Fame'),
    _QAItem(LucideIcons.shoppingBag, 'Prodavnica'),
    _QAItem(LucideIcons.creditCard, 'Historija clanarine'),
    _QAItem(LucideIcons.package, 'Historija narudzbi'),
    _QAItem(LucideIcons.star, 'Moje recenzije'),
    _QAItem(LucideIcons.presentation, 'Seminari'),
    _QAItem(LucideIcons.calendar, 'Termini'),
    _QAItem(LucideIcons.dumbbell, 'Treneri'),
    _QAItem(LucideIcons.apple, 'Nutricionisti'),
    _QAItem(LucideIcons.helpCircle, 'Cesta pitanja'),
  ];

  static final _screens = <Widget Function()>[
    () => const UserProgressScreen(),
    () => const LeaderboardScreen(),
    () => const SupplementShopScreen(),
    () => const MembershipHistoryScreen(),
    () => const OrderHistoryScreen(),
    () => const ReviewHistoryScreen(),
    () => const SeminarScreen(),
    () => const AppointmentScreen(),
    () => const TrainerListScreen(),
    () => const NutritionistListScreen(),
    () => const FaqScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Brzi pristup'),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(_items.length, (i) {
          return _tile(context, _items[i], _screens[i]);
        }),
      ],
    );
  }

  Widget _tile(BuildContext context, _QAItem item, Widget Function() builder) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => builder()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.listItemPadding,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodyBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textDark,
            size: 18,
          ),
        ]),
      ),
    );
  }
}

class _QAItem {
  final IconData icon;
  final String label;
  const _QAItem(this.icon, this.label);
}
