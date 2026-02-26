import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/cart_models.dart';
import '../utils/image_utils.dart';
import 'package:stronghold_core/stronghold_core.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            width: 56,
            height: 56,
            child: _image(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
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
                '${item.supplement.price.toStringAsFixed(2)} KM',
                style: AppTextStyles.bodyBold
                    .copyWith(color: AppColors.navyBlue),
              ),
            ],
          ),
        ),
        _stepper(),
        GestureDetector(
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _stepper() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(LucideIcons.minus, () => onQuantityChanged(item.quantity - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('${item.quantity}', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
        ),
        _stepBtn(LucideIcons.plus, () => onQuantityChanged(item.quantity + 1)),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 14),
      ),
    );
  }

  Widget _image() {
    if (item.supplement.imageUrl != null &&
        item.supplement.imageUrl!.isNotEmpty) {
      return Image.network(
        getFullImageUrl(item.supplement.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
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
