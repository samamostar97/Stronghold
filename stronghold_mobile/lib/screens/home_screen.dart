import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/home_appointments_carousel.dart';
import '../widgets/home_stats_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final name = user?.firstName ?? '';
    final imageUrl = user?.profileImageUrl;
    final unreadCount = ref.watch(userNotificationProvider).unreadCount;
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // ── Header: Avatar | Greeting + Name | Bell ──
              _header(name, imageUrl, unreadCount)
                  .animate()
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve),
              const SizedBox(height: AppSpacing.xl),
              // ── Stats label ──
              Text('Moj napredak',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.md),
              // ── Stats Carousel ──
              progressAsync.when(
                loading: () => const SizedBox(
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (progress) => HomeStatsCarousel(progress: progress),
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.06,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xxl),
              // ── Appointments label ──
              Text('Termini i Seminari',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.md),
              // ── Appointments Carousel ──
              const HomeAppointmentsCarousel()
                  .animate(delay: 300.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xxl),
              // ── Shop card ──
              Text('Kupovina',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.orange.withValues(alpha: 0.15),
                borderColor: AppColors.orange.withValues(alpha: 0.3),
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.huge,
                      vertical: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.orange.withValues(alpha: 0.3),
                                AppColors.orange.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.orange.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(LucideIcons.shoppingBag,
                              color: AppColors.orange, size: 40),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prodavnica',
                                  style: AppTextStyles.headingSm
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Suplementi i dodaci',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  )),
                              const SizedBox(height: AppSpacing.md),
                              GestureDetector(
                                onTap: () => context.push('/shop'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs + 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
                                    border: Border.all(
                                      color: AppColors.orange
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Shop',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(delay: 450.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String name, String? imageUrl, int unreadCount) {
    final fullImageUrl =
        imageUrl != null ? getFullImageUrl(imageUrl) : null;

    return Row(
      children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: SizedBox(
            width: 44,
            height: 44,
            child: fullImageUrl != null && fullImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: fullImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholderAvatar(name),
                    errorWidget: (_, __, ___) => _placeholderAvatar(name),
                  )
                : _placeholderAvatar(name),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Greeting + name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: AppTextStyles.bodyMd,
              ),
              Text(
                name,
                style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Notification bell
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    LucideIcons.bell,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              if (unreadCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderAvatar(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.isNotEmpty && parts.first.isNotEmpty
            ? parts.first[0].toUpperCase()
            : '?');

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.accentGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.headingSm.copyWith(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }
}
