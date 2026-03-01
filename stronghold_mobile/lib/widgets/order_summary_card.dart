import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

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
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ukupno', style: AppTextStyles.bodyMd),
              Text(
                '${totalAmount.toStringAsFixed(2)} KM',
                style: AppTextStyles.headingMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              icon: const Icon(LucideIcons.creditCard, size: 16),
              label: Text(
                'Nastavi na placanje',
                style: AppTextStyles.buttonMd.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
