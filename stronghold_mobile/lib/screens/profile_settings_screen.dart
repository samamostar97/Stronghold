import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_image_picker.dart';
import 'address_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

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
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text('Profil', style: AppTextStyles.headingLg),
              const SizedBox(height: AppSpacing.xl),
              // User card - tappable for image change
              _userCard(user),
              const SizedBox(height: AppSpacing.xxl),
              // Settings section
              Text('POSTAVKE',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.md),
              _navOption(
                icon: LucideIcons.mapPin,
                color: AppColors.secondary,
                title: 'Adresa za dostavu',
                subtitle: 'Dodaj ili promijeni adresu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddressScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _navOption(
                icon: LucideIcons.lock,
                color: AppColors.accent,
                title: 'Promijeni lozinku',
                subtitle: 'Azuriraj svoju lozinku',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Logout
              _logoutButton(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
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

    return GlassCard(
      onTap: () => _openImagePicker(rawImageUrl),
      child: Row(
        children: [
          AvatarWidget(
            initials: initials,
            size: 56,
            imageUrl: displayImageUrl,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headingSm),
                const SizedBox(height: 2),
                Text(email,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(LucideIcons.camera,
              color: AppColors.textDark, size: 18),
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
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                Text(subtitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight,
              color: AppColors.textDark, size: 18),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return GestureDetector(
      onTap: _isLoggingOut ? null : _handleLogout,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
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
                  const Icon(LucideIcons.logOut,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'ODJAVI SE',
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
