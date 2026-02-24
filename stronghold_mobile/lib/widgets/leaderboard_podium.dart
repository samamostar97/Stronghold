import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntryResponse> top3;

  const LeaderboardPodium({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (top3.length > 1)
          _podiumItem(top3[1], 2, 100)
        else
          const SizedBox(width: 100),
        const SizedBox(width: AppSpacing.sm),
        _podiumItem(top3[0], 1, 130),
        const SizedBox(width: AppSpacing.sm),
        if (top3.length > 2)
          _podiumItem(top3[2], 3, 80)
        else
          const SizedBox(width: 100),
      ],
    );
  }

  Widget _podiumItem(LeaderboardEntryResponse entry, int position, double height) {
    final posLabel =
        position == 1 ? '1st' : position == 2 ? '2nd' : '3rd';

    return Column(children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: entry.profileImageUrl != null &&
                  entry.profileImageUrl!.isNotEmpty
              ? Image.network(
                  getFullImageUrl(entry.profileImageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _initialsAvatar(entry),
                )
              : _initialsAvatar(entry),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      SizedBox(
        width: 100,
        child: Text(
          entry.fullName,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text('Level ${entry.level}',
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary)),
      const SizedBox(height: AppSpacing.md),
      Container(
        width: 100,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.6),
            ],
          ),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(posLabel,
                style: AppTextStyles.stat.copyWith(
                  fontSize: position == 1 ? 28 : 22,
                  color: AppColors.background,
                )),
            const SizedBox(height: AppSpacing.xs),
            Text('${entry.currentXP} XP',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.background.withValues(alpha: 0.8),
                )),
          ],
        ),
      ),
    ]);
  }

  Widget _initialsAvatar(LeaderboardEntryResponse entry) {
    final parts = entry.fullName.split(' ');
    var initials = parts[0][0].toUpperCase();
    if (parts.length > 1) initials += parts[1][0].toUpperCase();

    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(initials,
            style: AppTextStyles.headingSm
                .copyWith(color: AppColors.primary)),
      ),
    );
  }
}
