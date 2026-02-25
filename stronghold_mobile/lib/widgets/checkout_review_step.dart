import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/cart_models.dart';
import 'checkout_item_card.dart';
import 'checkout_summary_row.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'section_header.dart';

class CheckoutReviewStep extends StatelessWidget {
  final List<CartItem> items;
  final double total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const CheckoutReviewStep({
    super.key,
    required this.items,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Stavke narudzbe'),
                const SizedBox(height: AppSpacing.md),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: CheckoutItemCard(item: item),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Column(
                    children: [
                      CheckoutSummaryRow(
                        label: 'Subtotal',
                        value: '${total.toStringAsFixed(2)} KM',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CheckoutSummaryRow(
                        label: 'Dostava',
                        value: 'Besplatna',
                        valueColor: AppColors.success,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      CheckoutSummaryRow(
                        label: 'Ukupno',
                        value: '${total.toStringAsFixed(2)} KM',
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.arrowLeft,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Nazad', style: AppTextStyles.buttonMd),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: 'Nastavi',
              icon: LucideIcons.arrowRight,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
