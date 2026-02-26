import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntryResponse entry;

  const LeaderboardRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.navyBlue, width: 1.5),
          ),
          child: Center(
            child: Text('#${entry.rank}',
                style:
                    AppTextStyles.bodyBold.copyWith(color: AppColors.navyBlue)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.navyBlue, width: 2),
          ),
          child: ClipOval(
            child: entry.profileImageUrl != null &&
                    entry.profileImageUrl!.isNotEmpty
                ? Image.network(
                    getFullImageUrl(entry.profileImageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _initialsAvatar(),
                  )
                : _initialsAvatar(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.fullName,
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              Text('${entry.currentXP} XP', style: AppTextStyles.bodySm),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.navyBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.navyBlue),
          ),
          child: Text(
            'LVL ${entry.level}',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.navyBlue,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _initialsAvatar() {
    final parts = entry.fullName.split(' ');
    var initials = parts[0][0].toUpperCase();
    if (parts.length > 1) initials += parts[1][0].toUpperCase();

    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(initials,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
      ),
    );
  }
}
