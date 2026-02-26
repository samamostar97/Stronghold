import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/professional_card.dart';
import 'book_appointment_screen.dart';

class NutritionistListScreen extends ConsumerWidget {
  const NutritionistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionistsAsync = ref.watch(nutritionistsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                  child: Text(
                      'Nutricionisti', style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(
            child: nutritionistsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message:
                    ErrorHandler.message(error),
                onRetry: () => ref.invalidate(nutritionistsProvider),
              ),
              data: (nutritionists) {
                if (nutritionists.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.apple,
                    title: 'Nema dostupnih nutricionista',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  itemCount: nutritionists.length,
                  itemBuilder: (_, i) {
                    final n = nutritionists[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ProfessionalCard(
                        icon: LucideIcons.apple,
                        name: n.fullName,
                        phone: n.phoneNumber,
                        email: n.email,
                        onTap: () => context.push(
                          '/book-appointment',
                          extra: BookAppointmentArgs(
                            staffId: n.id,
                            staffName: n.fullName,
                            staffType: StaffType.nutritionist,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ).animate(delay: 100.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(begin: 0.04, end: 0, duration: Motion.smooth, curve: Motion.curve),
        ]),
      ),
    );
  }
}
