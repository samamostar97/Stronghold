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
import '../utils/image_utils.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/shared/surface_card.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  bool _isLoggingOut = false;
  String? _localImageUrl;
  bool _imageOverridden = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      ref.read(cartProvider.notifier).clear();
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil', style: AppTextStyles.headingLg),
              const SizedBox(height: AppSpacing.lg),
              _userCard(user),
              const SizedBox(height: AppSpacing.xl),
              Text('Postavke racuna', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.mapPin,
                color: AppColors.secondary,
                title: 'Adresa za dostavu',
                subtitle: 'Dodaj ili promijeni adresu',
                onTap: () => context.push('/address'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.package,
                color: AppColors.primary,
                title: 'Moje narudzbe',
                subtitle: 'Historija narudzbi',
                onTap: () => context.push('/orders'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.star,
                color: AppColors.warning,
                title: 'Moje recenzije',
                subtitle: 'Pregled i upravljanje recenzijama',
                onTap: () => context.push('/reviews'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.helpCircle,
                color: AppColors.textMuted,
                title: 'FAQ',
                subtitle: 'Cesta pitanja i odgovori',
                onTap: () => context.push('/faq'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.lock,
                color: AppColors.accent,
                title: 'Promijeni lozinku',
                subtitle: 'Azuriraj svoju lozinku',
                onTap: () => context.push('/change-password'),
              ),
              const SizedBox(height: AppSpacing.xl),
              _logoutButton(),
            ],
          ),
        ).animate().fadeIn(duration: Motion.smooth, curve: Motion.curve),
      ),
    );
  }

  Widget _userCard(dynamic user) {
    final name = user?.displayName ?? '';
    final email = user?.email ?? '';
    final rawImageUrl = user?.profileImageUrl;
    final initials = _getInitials(name);

    final displayImageUrl = _imageOverridden
        ? (_localImageUrl != null ? getFullImageUrl(_localImageUrl!) : null)
        : (rawImageUrl != null ? getFullImageUrl(rawImageUrl) : null);

    return SurfaceCard(
      onTap: () => _openImagePicker(rawImageUrl),
      child: Row(
        children: [
          AvatarWidget(initials: initials, size: 56, imageUrl: displayImageUrl),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headingSm),
                const SizedBox(height: 2),
                Text(email, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          const Icon(LucideIcons.camera, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }

  Widget _navOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: _isLoggingOut ? null : _handleLogout,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: _isLoggingOut
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.logOut,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Odjavi se',
                    style: AppTextStyles.label.copyWith(color: AppColors.error),
                  ),
                ],
              ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$last'.toUpperCase();
  }
}
