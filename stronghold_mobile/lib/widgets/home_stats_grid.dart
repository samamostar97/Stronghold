import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/profile_provider.dart';
import 'stat_card_compact.dart';

class HomeStatsGrid extends ConsumerWidget {
  const HomeStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return progress.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) {
        final visits = data.weeklyVisits.where((v) => v.minutes > 0).length;
        return Column(children: [
          Row(children: [
            Expanded(
              child: StatCardCompact(
                label: 'Level',
                value: '${data.level}',
                icon: LucideIcons.trophy,
                accentColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCardCompact(
                label: 'XP',
                value: '${data.currentXP}',
                icon: LucideIcons.zap,
                accentColor: AppColors.primary,
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
              child: StatCardCompact(
                label: 'Posjete (sedmica)',
                value: '$visits',
                icon: LucideIcons.activity,
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCardCompact(
                label: 'Vrijeme (sedmica)',
                value: data.formattedWeeklyTime,
                icon: LucideIcons.clock,
                accentColor: AppColors.accent,
              ),
            ),
          ]),
        ]);
      },
    );
  }
}
