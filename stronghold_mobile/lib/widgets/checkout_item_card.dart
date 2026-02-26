import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/cart_models.dart';
import '../utils/image_utils.dart';
import 'package:stronghold_core/stronghold_core.dart';

class CheckoutItemCard extends StatelessWidget {
  final CartItem item;

  const CheckoutItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              width: 48,
              height: 48,
              child: item.supplement.imageUrl != null
                  ? Image.network(
                      getFullImageUrl(item.supplement.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.supplement.name,
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.supplement.price.toStringAsFixed(2)} KM x ${item.quantity}',
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Total
          Text(
            '${item.totalPrice.toStringAsFixed(2)} KM',
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.navyBlue),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textDark, size: 20),
      ),
    );
  }
}
