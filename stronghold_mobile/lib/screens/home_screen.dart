import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/home_appointments_carousel.dart';
import '../widgets/home_stats_carousel.dart';
import '../widgets/shared/surface_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final displayName = user?.displayName.trim() ?? '';
    final name = displayName.isNotEmpty
        ? displayName
        : (user?.firstName ?? 'Clan');
    final imageUrl = user?.profileImageUrl;
    final unreadCount = ref.watch(userNotificationProvider).unreadCount;
    final cartCount = ref.watch(cartProvider).itemCount;
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(
                context,
                name: name,
                imageUrl: imageUrl,
                unreadCount: unreadCount,
                cartCount: cartCount,
              ).animate().fadeIn(duration: Motion.smooth, curve: Motion.curve),
              const SizedBox(height: AppSpacing.lg),
              _heroBanner(context)
                  .animate(delay: 80.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xl),
              _sectionHeader(
                title: 'Napredak',
                actionLabel: 'Detalji',
                onTap: () => context.push('/progress'),
              ),
              const SizedBox(height: AppSpacing.md),
              progressAsync
                  .when(
                    loading: () => const SizedBox(
                      height: 188,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    error: (_, __) => SurfaceCard(
                      child: Text(
                        'Napredak trenutno nije dostupan. Pokusajte ponovo kasnije.',
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                    data: (progress) => HomeStatsCarousel(progress: progress),
                  )
                  .animate(delay: 160.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xl),
              _sectionHeader(
                title: 'Plan treninga',
                actionLabel: 'Svi termini',
                onTap: () => context.go('/appointments'),
              ),
              const SizedBox(height: AppSpacing.md),
              const HomeAppointmentsCarousel()
                  .animate(delay: 220.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context, {
    required String name,
    required String? imageUrl,
    required int unreadCount,
    required int cartCount,
  }) {
    final fullImageUrl = imageUrl != null ? getFullImageUrl(imageUrl) : null;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: SizedBox(
            width: 48,
            height: 48,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: AppTextStyles.bodySm),
              const SizedBox(height: 2),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headingSm.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        _headerActionButton(
          icon: LucideIcons.bell,
          badgeCount: unreadCount,
          onTap: () => context.push('/notifications'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _headerActionButton(
          icon: LucideIcons.shoppingCart,
          badgeCount: cartCount,
          onTap: () => context.push('/cart'),
        ),
      ],
    );
  }

  Widget _heroBanner(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.cyan.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tvoj trening plan je spreman',
                    style: AppTextStyles.headingSm,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Rezervisi termin ili pregledaj suplemente za ovu sedmicu.',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _actionButton(
                        label: 'Termini',
                        icon: LucideIcons.calendarClock,
                        onTap: () => context.go('/appointments'),
                      ),
                      _actionButton(
                        label: 'Shop',
                        icon: LucideIcons.shoppingBag,
                        onTap: () => context.go('/shop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headingSm)),
        InkWell(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerActionButton({
    required IconData icon,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 18, color: AppColors.textPrimary)),
            if (badgeCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
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
      decoration: const BoxDecoration(gradient: AppColors.accentGradient),
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
