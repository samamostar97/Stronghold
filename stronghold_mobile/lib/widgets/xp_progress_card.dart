import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class XpProgressCard extends StatelessWidget {
  final UserProgressResponse progress;
  final Animation<double> animation;

  const XpProgressCard({
    super.key,
    required this.progress,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevel = progress.level < 10 ? progress.level + 1 : 10;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Napredak do Level $nextLevel',
                    style: AppTextStyles.headingSm,
                    overflow: TextOverflow.ellipsis),
              ),
              Text('${progress.progressPercentage.toStringAsFixed(1)}%',
                  style:
                      AppTextStyles.bodyBold.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor:
                      (progress.progressPercentage / 100) * animation.value,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${progress.xpProgress} XP',
                  style: AppTextStyles.bodySm),
              Text('${progress.xpForNextLevel} XP',
                  style: AppTextStyles.bodySm),
            ],
          ),
        ],
      ),
    );
  }
}
