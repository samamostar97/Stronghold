import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/supplement_provider.dart';
import '../utils/image_utils.dart';
import 'shared/surface_card.dart';

class ShopCategorySection extends ConsumerWidget {
  const ShopCategorySection({
    super.key,
    required this.category,
    required this.onSupplementTap,
    required this.onAddToCart,
    required this.onViewAll,
  });

  final SupplementCategoryResponse category;
  final void Function(SupplementResponse) onSupplementTap;
  final void Function(SupplementResponse) onAddToCart;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplementsAsync = ref.watch(
      supplementsByCategoryProvider(category.id),
    );

    return supplementsAsync.when(
      loading: () => _shimmerPlaceholder(),
      error: (_, __) => const SizedBox.shrink(),
      data: (supplements) {
        if (supplements.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(category.name, style: AppTextStyles.headingSm),
                  ),
                  InkWell(
                    onTap: onViewAll,
                    child: Text(
                      'Pogledaj sve',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 206,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: supplements.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) => _CategorySupplementCard(
                  supplement: supplements[i],
                  onTap: () => onSupplementTap(supplements[i]),
                  onAddToCart: () => onAddToCart(supplements[i]),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  Widget _shimmerPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _CategorySupplementCard extends StatelessWidget {
  final SupplementResponse supplement;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _CategorySupplementCard({
    required this.supplement,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: SurfaceCard(
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
                height: 104,
                width: double.infinity,
                child: _image(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
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
                        InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.plus,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    if (supplement.imageUrl != null && supplement.imageUrl!.isNotEmpty) {
      return Image.network(
        getFullImageUrl(supplement.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textMuted, size: 24),
      ),
    );
  }
}
