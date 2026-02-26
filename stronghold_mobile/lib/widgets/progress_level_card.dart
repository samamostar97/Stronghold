import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class ProgressLevelCard extends StatelessWidget {
  final UserProgressResponse progress;

  const ProgressLevelCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text('LVL',
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(progress.fullName,
                      style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    const Icon(LucideIcons.star,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Level ${progress.level}',
                        style: AppTextStyles.statSm
                            .copyWith(color: AppColors.warning)),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                  LucideIcons.zap, '${progress.currentXP}', 'Ukupno XP'),
              _statItem(LucideIcons.timer, progress.formattedWeeklyTime,
                  'Ovaj tjedan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(children: [
      Icon(icon, color: AppColors.navyBlue, size: 22),
      const SizedBox(height: AppSpacing.sm),
      Text(value, style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
      Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white)),
    ]);
  }
}
