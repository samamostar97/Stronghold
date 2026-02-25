import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/leaderboard_provider.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../widgets/shared/hover_icon_button.dart';
import '../widgets/leaderboard/leaderboard_table.dart';
import '../widgets/shared/shimmer_loading.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HoverIconButton(
                    icon: LucideIcons.refreshCw,
                    onTap: () => ref.invalidate(leaderboardProvider),
                    tooltip: 'Osvjezi',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: leaderboardAsync.when(
                  loading: () => const ShimmerTable(
                      columnFlex: [1, 4, 2, 2], rowCount: 10),
                  error: (error, _) => Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Greska pri ucitavanju',
                              style: AppTextStyles.headingSm),
                          const SizedBox(height: AppSpacing.sm),
                          Text(error.toString(),
                              style: AppTextStyles.bodyMd,
                              textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
                          GradientButton.text(
                            text: 'Pokusaj ponovo',
                            onPressed: () =>
                                ref.invalidate(leaderboardProvider),
                          ),
                        ]),
                  ),
                  data: (entries) => LeaderboardTable(entries: entries),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
