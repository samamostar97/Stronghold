import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'gradient_button.dart';

class OrderSummaryCard extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onCheckout;

  const OrderSummaryCard({
    super.key,
    required this.totalAmount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ukupno:', style: AppTextStyles.bodyLg),
              Text(
                '${totalAmount.toStringAsFixed(2)} KM',
                style: AppTextStyles.headingMd
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'NASTAVI NA PLACANJE',
            icon: LucideIcons.creditCard,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}
