import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/supplement_models.dart';
import '../providers/cart_provider.dart';
import '../providers/supplement_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/review_card.dart';
import '../widgets/section_header.dart';
import '../widgets/supplement_detail_header.dart';

class SupplementDetailScreen extends ConsumerWidget {
  final Supplement supplement;

  const SupplementDetailScreen({super.key, required this.supplement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(supplementReviewsProvider(supplement.id));

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
              Expanded(
                child: Text(
                  supplement.name,
                  style: AppTextStyles.headingMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SupplementDetailHeader(supplement: supplement),
                  const SizedBox(height: AppSpacing.xxl),
                  _reviewsSection(reviewsAsync),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: GradientButton(
              label: 'DODAJ U KORPU',
              icon: LucideIcons.shoppingCart,
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(supplement);
                showSuccessFeedback(
                    context, '${supplement.name} dodano u korpu');
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _reviewsSection(AsyncValue<List<SupplementReview>> reviewsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recenzije'),
        const SizedBox(height: AppSpacing.md),
        reviewsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
          error: (_, _) => GlassCard(
            child: Text(
              'Greska prilikom ucitavanja recenzija',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return GlassCard(
                child: Center(
                  child: Text('Nema recenzija', style: AppTextStyles.bodyMd),
                ),
              );
            }
            final avg = reviews.fold<int>(0, (s, r) => s + r.rating) /
                reviews.length;
            return Column(children: [
              _ratingSummary(avg, reviews.length),
              const SizedBox(height: AppSpacing.md),
              ...reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ReviewCard(review: r),
                  )),
            ]);
          },
        ),
      ],
    );
  }

  Widget _ratingSummary(double avg, int count) {
    return GlassCard(
      child: Row(children: [
        Text(avg.toStringAsFixed(1), style: AppTextStyles.stat),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewCard.starRating(avg, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text('$count recenzija', style: AppTextStyles.bodySm),
          ],
        ),
      ]),
    );
  }
}
