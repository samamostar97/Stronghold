import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/home_explore_grid.dart';
import '../widgets/home_notifications.dart';
import '../widgets/warrior_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = user?.firstName ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Greeting
              Text(_greeting(), style: AppTextStyles.bodyMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                style: AppTextStyles.headingLg,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Warrior Banner
              const WarriorBanner(),
              const SizedBox(height: AppSpacing.xxl),
              // Notifications
              const HomeNotifications(),
              const SizedBox(height: AppSpacing.xxl),
              // Explore grid
              const HomeExploreGrid(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
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
