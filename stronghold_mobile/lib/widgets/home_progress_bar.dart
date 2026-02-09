import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import '../screens/user_progress_screen.dart';
import 'glass_card.dart';

class HomeProgressBar extends ConsumerWidget {
  const HomeProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return progress.when(
      loading: () => _loadingCard(),
      error: (_, _) => const SizedBox.shrink(),
      data: (p) => GlassCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProgressScreen()),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(LucideIcons.trendingUp,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Level ${p.level}', style: AppTextStyles.bodyBold),
                const Spacer(),
                Text(
                  '${p.xpProgress} / ${p.xpForNextLevel} XP',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.progressPercentage / 100,
                minHeight: 6,
                backgroundColor: AppColors.surface,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return const GlassCard(
      child: SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
