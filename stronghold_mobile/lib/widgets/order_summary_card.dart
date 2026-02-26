import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

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
        color: Colors.transparent,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ukupno:', style: AppTextStyles.bodyLg.copyWith(color: Colors.white)),
              Text(
                '${totalAmount.toStringAsFixed(2)} KM',
                style: AppTextStyles.headingMd
                    .copyWith(color: Colors.white),
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
