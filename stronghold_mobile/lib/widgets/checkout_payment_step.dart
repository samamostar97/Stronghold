import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/cart_models.dart';
import 'checkout_summary_row.dart';
import 'section_header.dart';

class CheckoutPaymentStep extends StatelessWidget {
  final List<CartItem> items;
  final double total;
  final AddressResponse? address;
  final bool isProcessing;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onPay;

  const CheckoutPaymentStep({
    super.key,
    required this.items,
    required this.total,
    this.address,
    required this.isProcessing,
    this.error,
    required this.onBack,
    required this.onPay,
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
                const SectionHeader(title: 'Pregled placanja'),
                const SizedBox(height: AppSpacing.md),
                // Order summary
                GlassCard(
                  child: Column(
                    children: [
                      CheckoutSummaryRow(
                        label: 'Stavke',
                        value: '${items.length} proizvoda',
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                        label: 'Ukupno za placanje',
                        value: '${total.toStringAsFixed(2)} KM',
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                // Delivery address
                if (address != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Adresa dostave'),
                  const SizedBox(height: AppSpacing.md),
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
                          ),
                          child: const Icon(LucideIcons.mapPin,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address!.street,
                                  style: AppTextStyles.bodyBold),
                              const SizedBox(height: 2),
                              Text(
                                '${address!.postalCode} ${address!.city}, ${address!.country}',
                                style: AppTextStyles.bodySm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Error message
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            size: 20, color: AppColors.error),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            error!,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        _bottomBar(),
      ],
    );
  }

  Widget _bottomBar() {
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
              onTap: isProcessing ? null : onBack,
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
              label: 'Plati ${total.toStringAsFixed(2)} KM',
              icon: LucideIcons.lock,
              isLoading: isProcessing,
              onPressed: isProcessing ? null : onPay,
            ),
          ),
        ],
      ),
    );
  }
}
