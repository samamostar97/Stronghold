import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'review_card.dart';

class ReviewHistoryCard extends StatelessWidget {
  final UserReviewResponse review;
  final bool isDeleting;
  final VoidCallback onDelete;

  const ReviewHistoryCard({
    super.key,
    required this.review,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(review.supplementName,
                    style: AppTextStyles.headingSm),
              ),
              const SizedBox(width: AppSpacing.md),
              ReviewCard.starRating(review.rating.toDouble()),
            ],
          ),
          if (review.comment != null &&
              review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(review.comment!,
                style: AppTextStyles.bodyMd.copyWith(height: 1.4)),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(LucideIcons.star,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Text('${review.rating}/5',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.textSecondary)),
              ]),
              GestureDetector(
                onTap: isDeleting ? null : onDelete,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.errorDim,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.trash2,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Obrisi',
                                style: AppTextStyles.badge
                                    .copyWith(color: AppColors.error)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
