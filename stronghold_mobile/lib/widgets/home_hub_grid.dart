import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/profile_provider.dart';
import '../screens/leaderboard_screen.dart';
import 'hub_card.dart';

class HomeHubGrid extends ConsumerWidget {
  final ValueChanged<int> onTabSwitch;

  const HomeHubGrid({super.key, required this.onTabSwitch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    final levelXp = progress.whenOrNull(
      data: (p) => 'Level ${p.level} / ${p.currentXP} XP',
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: HubCard(
                  icon: LucideIcons.trendingUp,
                  title: 'Moj napredak',
                  subtitle: levelXp ?? 'Ucitavanje...',
                  accentColor: AppColors.primary,
                  onTap: () => onTabSwitch(3),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HubCard(
                  icon: LucideIcons.calendar,
                  title: 'Termini',
                  subtitle: 'Zakazite termin',
                  accentColor: AppColors.secondary,
                  onTap: () => onTabSwitch(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: HubCard(
                  icon: LucideIcons.shoppingBag,
                  title: 'Prodavnica',
                  subtitle: 'Suplementi i oprema',
                  accentColor: AppColors.success,
                  onTap: () => onTabSwitch(1),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HubCard(
                  icon: LucideIcons.trophy,
                  title: 'Hall of Fame',
                  subtitle: 'Rang lista clanova',
                  accentColor: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
