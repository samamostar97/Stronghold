import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/progress_models.dart';
import '../providers/profile_provider.dart';
import '../screens/leaderboard_screen.dart';
import '../utils/image_utils.dart';
import 'avatar_widget.dart';
import 'glass_card.dart';

class HomeHallOfFameTeaser extends ConsumerWidget {
  const HomeHallOfFameTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return leaderboard.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final top3 = entries.take(3).toList();

        return Column(
          children: [
            // Header row
            Row(
              children: [
                const Icon(LucideIcons.trophy,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text('Hall of Fame', style: AppTextStyles.headingSm),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen()),
                  ),
                  child: Text('Vidi sve',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Top 3 cards
            GlassCard(
              child: Column(
                children: [
                  for (int i = 0; i < top3.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                    _entryRow(top3[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _entryRow(LeaderboardEntry entry) {
    final initials = _getInitials(entry.fullName);
    final medalColor = _medalColor(entry.rank);

    return Row(
      children: [
        // Rank
        SizedBox(
          width: 24,
          child: Text(
            '#${entry.rank}',
            style: AppTextStyles.bodyBold.copyWith(color: medalColor),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Avatar
        AvatarWidget(
          initials: initials,
          size: 32,
          imageUrl: entry.profileImageUrl != null
              ? getFullImageUrl(entry.profileImageUrl)
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        // Name
        Expanded(
          child: Text(
            entry.fullName,
            style: AppTextStyles.bodyBold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Level + XP
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Lvl ${entry.level}',
                style: AppTextStyles.bodySm.copyWith(color: medalColor)),
            Text('${entry.currentXP} XP', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$last'.toUpperCase();
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.textSecondary;
      case 3:
        return AppColors.orange;
      default:
        return AppColors.textMuted;
    }
  }
}
