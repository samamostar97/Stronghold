import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/faq_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/faq_accordion_item.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqsAsync = ref.watch(allFaqsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
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
                  child: Text('Cesta pitanja',
                      style: AppTextStyles.headingMd.copyWith(color: Colors.white))),
            ]),
          ),
          Expanded(
            child: faqsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (error, _) => AppErrorState(
                message: ErrorHandler.message(error),
                onRetry: () =>
                    ref.invalidate(allFaqsProvider),
              ),
              data: (faqs) {
                if (faqs.isEmpty) {
                  return const AppEmptyState(
                    icon: LucideIcons.helpCircle,
                    title: 'Nema cestih pitanja',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  itemCount: faqs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.md),
                    child: FaqAccordionItem(faq: faqs[i])
                        .animate(delay: Duration(milliseconds: 50 * i))
                        .fadeIn(duration: Motion.normal, curve: Motion.curve)
                        .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: Motion.normal,
                          curve: Motion.curve,
                        ),
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
