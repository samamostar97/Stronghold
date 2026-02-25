import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class ReviewCard extends StatelessWidget {
  final SupplementReviewResponse review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                review.userName,
                style: AppTextStyles.bodyBold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${review.createdAt.day}.${review.createdAt.month}.${review.createdAt.year}.',
              style: AppTextStyles.caption,
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          starRating(review.rating.toDouble()),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.comment!,
              style: AppTextStyles.bodyMd.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  static Widget starRating(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          LucideIcons.star,
          color: i < rating.floor() ? AppColors.warning : AppColors.textDark,
          size: size,
        );
      }),
    );
  }
}
