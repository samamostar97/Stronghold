import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/home_explore_grid.dart';
import '../widgets/home_notifications.dart';
import '../widgets/warrior_banner.dart';
import 'navigation_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final name = user?.firstName ?? '';

    // Refresh notifications when user switches back to home tab
    final currentIndex = ref.watch(bottomNavIndexProvider);
    if (_previousIndex != null && _previousIndex != 0 && currentIndex == 0) {
      Future.microtask(() {
        ref.read(userNotificationProvider.notifier).load();
      });
    }
    _previousIndex = currentIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Greeting
              Text(_greeting(), style: AppTextStyles.bodyMd)
                  .animate()
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                style: AppTextStyles.headingLg.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideX(
                    begin: -0.03,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xl),
              // Warrior Banner
              const WarriorBanner()
                  .animate(delay: 200.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.06,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xxl),
              // Notifications
              const HomeNotifications()
                  .animate(delay: 350.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
              const SizedBox(height: AppSpacing.xxl),
              // Explore grid
              const HomeExploreGrid()
                  .animate(delay: 500.ms)
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }
}
