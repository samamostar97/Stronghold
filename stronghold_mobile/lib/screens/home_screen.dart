import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/home_membership_card.dart';
import '../widgets/home_quick_access.dart';
import '../widgets/home_recommendations.dart';
import '../widgets/home_stats_grid.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userName;
  final String? userImageUrl;
  final bool hasActiveMembership;

  const HomeScreen({
    super.key,
    required this.userName,
    this.userImageUrl,
    required this.hasActiveMembership,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      ref.read(cartProvider.notifier).clear();
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                userName: widget.userName,
                userImageUrl: widget.userImageUrl,
              ),
              const SizedBox(height: AppSpacing.xxl),
              HomeMembershipCard(
                hasActiveMembership: widget.hasActiveMembership,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const HomeStatsGrid(),
              const SizedBox(height: AppSpacing.xxl),
              const HomeRecommendations(),
              const SizedBox(height: AppSpacing.xxl),
              const HomeQuickAccess(),
              const SizedBox(height: AppSpacing.xxl),
              _logoutButton(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return GestureDetector(
      onTap: _isLoggingOut ? null : _handleLogout,
      child: Container(
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
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(LucideIcons.logOut, color: AppColors.error, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'ODJAVI SE',
                  style: AppTextStyles.label.copyWith(color: AppColors.error),
                ),
              ]),
      ),
    );
  }
}
