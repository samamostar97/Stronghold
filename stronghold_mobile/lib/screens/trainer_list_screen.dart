import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/appointment_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/professional_card.dart';
import 'book_appointment_screen.dart';

class TrainerListScreen extends ConsumerWidget {
  const TrainerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainersAsync = ref.watch(trainersProvider);

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
                  child: Text('Treneri', style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(
            child: trainersAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message:
                    ErrorHandler.message(error),
                onRetry: () => ref.invalidate(trainersProvider),
              ),
              data: (trainers) {
                if (trainers.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.dumbbell,
                    title: 'Nema dostupnih trenera',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  itemCount: trainers.length,
                  itemBuilder: (_, i) {
                    final t = trainers[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ProfessionalCard(
                        icon: LucideIcons.dumbbell,
                        name: t.fullName,
                        phone: t.phoneNumber,
                        email: t.email,
                        onTap: () => context.push(
                          '/book-appointment',
                          extra: BookAppointmentArgs(
                            staffId: t.id,
                            staffName: t.fullName,
                            staffType: StaffType.trainer,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
