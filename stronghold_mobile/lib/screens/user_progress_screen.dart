import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/profile_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/progress_level_card.dart';
import '../widgets/xp_progress_card.dart';
import '../widgets/weekly_activity_chart.dart';

class UserProgressScreen extends ConsumerStatefulWidget {
  const UserProgressScreen({super.key});

  @override
  ConsumerState<UserProgressScreen> createState() =>
      _UserProgressScreenState();
}

class _UserProgressScreenState extends ConsumerState<UserProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Personalni napredak',
                      style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(
            child: progressAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message:
                    ErrorHandler.message(error),
                onRetry: () => ref.invalidate(userProgressProvider),
              ),
              data: (progress) {
                _animCtrl.forward();
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: Column(children: [
                    ProgressLevelCard(progress: progress)
                        .animate()
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    XpProgressCard(
                        progress: progress, animation: _anim)
                        .animate(delay: 150.ms)
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    WeeklyActivityChart(
                        visits: progress.weeklyVisits,
                        animation: _anim)
                        .animate(delay: 300.ms)
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
