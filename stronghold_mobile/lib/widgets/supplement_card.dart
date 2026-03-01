import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';
import 'shared/surface_card.dart';

class SupplementCard extends StatelessWidget {
  final SupplementResponse supplement;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const SupplementCard({
    super.key,
    required this.supplement,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: _image(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplement.name,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  supplement.supplementCategoryName ?? '',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${supplement.price.toStringAsFixed(2)} KM',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (onAddToCart != null)
                      InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    if (supplement.imageUrl != null && supplement.imageUrl!.isNotEmpty) {
      return Image.network(
        getFullImageUrl(supplement.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textMuted, size: 28),
      ),
    );
  }
}
