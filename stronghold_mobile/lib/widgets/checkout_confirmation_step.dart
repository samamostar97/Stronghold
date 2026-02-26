import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class CheckoutConfirmationStep extends StatelessWidget {
  final AddressResponse? address;

  const CheckoutConfirmationStep({
    super.key,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        children: [
          const Spacer(),
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 3),
            ),
            child: const Icon(
              LucideIcons.check,
              size: 36,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Narudzba uspjesna!', style: AppTextStyles.headingLg.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vasa narudzba je uspjesno kreirana.',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          // Delivery address
          if (address != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
                    ),
                    child: const Icon(LucideIcons.truck,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dostava na adresu',
                            style: AppTextStyles.caption.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          '${address!.street}, ${address!.postalCode} ${address!.city}',
                          style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          // Bottom actions
          GradientButton(
            label: 'Moje narudzbe',
            icon: LucideIcons.package,
            onPressed: () {
              context.go('/orders');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {
              context.go('/shop');
            },
            child: Container(
              width: double.infinity,
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
                    const Icon(LucideIcons.shoppingBag,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Nastavi kupovinu', style: AppTextStyles.buttonMd),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
