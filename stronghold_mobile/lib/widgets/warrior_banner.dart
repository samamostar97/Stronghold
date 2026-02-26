import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/navigation_shell.dart';
import '../utils/image_utils.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'profile_image_picker.dart';

class WarriorBanner extends ConsumerStatefulWidget {
  const WarriorBanner({super.key});

  @override
  ConsumerState<WarriorBanner> createState() => _WarriorBannerState();
}

class _WarriorBannerState extends ConsumerState<WarriorBanner> {
  String? _localImageUrl;
  bool _imageOverridden = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final progressAsync = ref.watch(userProgressProvider);
    final membershipAsync = ref.watch(membershipHistoryProvider);

    final name = user?.displayName ?? '';
    final rawImageUrl = user?.profileImageUrl;
    final displayImageUrl = _imageOverridden
        ? (_localImageUrl != null ? getFullImageUrl(_localImageUrl!) : null)
        : (rawImageUrl != null ? getFullImageUrl(rawImageUrl) : null);

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with level badge - tappable for image change
              GestureDetector(
                onTap: () => _openImagePicker(rawImageUrl),
                child: _avatarWithBadge(
                  imageUrl: displayImageUrl,
                  level: progressAsync.valueOrNull?.level,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Name + membership status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.headingSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _membershipStatus(membershipAsync),
                  ],
                ),
              ),
              // Settings icon - switches to Profile tab
              IconButton(
                onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                icon: const Icon(
                  LucideIcons.settings,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // XP progress bar
          _xpProgressBar(progressAsync),
        ],
      ),
    );
  }

  void _openImagePicker(String? currentImageUrl) {
    showProfileImagePicker(
      context: context,
      ref: ref,
      currentImageUrl: currentImageUrl,
      onChanged: (newUrl) {
        setState(() {
          _localImageUrl = newUrl;
          _imageOverridden = true;
        });
        ref.read(authProvider.notifier).updateProfileImage(newUrl);
      },
    );
  }

  Widget _avatarWithBadge({String? imageUrl, int? level}) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholderAvatar(),
                      errorWidget: (_, __, ___) => _placeholderAvatar(),
                    )
                  : _placeholderAvatar(),
            ),
          ),
          if (level != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                ),
                child: Text(
                  'LV$level',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholderAvatar() {
    final user = ref.read(authProvider).user;
    final name = user?.displayName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first[0].toUpperCase()
            : '?');

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.headingSm.copyWith(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _membershipStatus(AsyncValue<dynamic> membershipAsync) {
    return membershipAsync.when(
      loading: () => Text('Ucitavanje...', style: AppTextStyles.bodySm),
      error: (_, __) => Text('Neaktivna clanarina',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
      data: (payments) {
        final List<dynamic> list = payments;
        final active = list.where((p) => p.isActive).toList();
        if (active.isEmpty) {
          return Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Neaktivna clanarina',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
            ],
          );
        }
        final membership = active.first;
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                membership.packageName,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _xpProgressBar(AsyncValue<dynamic> progressAsync) {
    return progressAsync.when(
      loading: () => const SizedBox(
        height: 20,
        child: LinearProgressIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceElevated,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (progress) {
        final pct = (progress.progressPercentage / 100).clamp(0.0, 1.0);
        final current = progress.xpProgress;
        final needed = progress.xpForNextLevel;
        final nextLevel = progress.level + 1;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$current / $needed XP',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'do Level $nextLevel',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.toDouble(),
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceElevated,
              ),
            ),
          ],
        );
      },
    );
  }
}
