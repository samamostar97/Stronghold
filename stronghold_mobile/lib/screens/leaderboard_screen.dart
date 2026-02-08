import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_row.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
              const Icon(LucideIcons.trophy,
                  color: AppColors.warning, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: Text(
                      'Hall of Fame', style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message:
                    error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(leaderboardProvider),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.trophy,
                    title: 'Nema podataka za prikaz',
                  );
                }
                _animCtrl.forward();
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    child: Column(children: [
                      const SizedBox(height: AppSpacing.xl),
                      LeaderboardPodium(
                          top3: entries.take(3).toList()),
                      const SizedBox(height: AppSpacing.xxxl),
                      ...entries.skip(3).map((e) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.md),
                            child: LeaderboardRow(entry: e),
                          )),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
