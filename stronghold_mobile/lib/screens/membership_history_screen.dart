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
import '../widgets/membership_payment_card.dart';

class MembershipHistoryScreen extends ConsumerWidget {
  const MembershipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(membershipHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Historija clanarine',
                      style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(
            child: paymentsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message: error
                    .toString()
                    .replaceFirst('Exception: ', ''),
                onRetry: () =>
                    ref.invalidate(membershipHistoryProvider),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.receipt,
                    title: 'Nemate evidentirane uplate',
                    subtitle:
                        'Vasa historija placanja ce se prikazati ovdje',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  itemCount: payments.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.md),
                    child: MembershipPaymentCard(
                        payment: payments[i]),
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
