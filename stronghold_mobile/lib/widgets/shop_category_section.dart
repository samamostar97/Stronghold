import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/supplement_provider.dart';
import '../utils/image_utils.dart';

/// A single category section: heading + horizontal scrollable supplement cards.
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
    final supplementsAsync = ref.watch(supplementsByCategoryProvider(category.id));

    return supplementsAsync.when(
      loading: () => _shimmerPlaceholder(),
      error: (_, __) => const SizedBox.shrink(),
      data: (supplements) {
        if (supplements.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppTextStyles.headingSm.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Pogledaj sve',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Horizontal list
            SizedBox(
              height: 200,
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
              color: Colors.white.withValues(alpha: 0.08),
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
                      color: Colors.white.withValues(alpha: 0.05),
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

// ─────────────────────────────────────────────────────────────────────────────
// SUPPLEMENT CARD (for horizontal category sections)
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySupplementCard extends StatelessWidget {
  const _CategorySupplementCard({
    required this.supplement,
    required this.onTap,
    required this.onAddToCart,
  });

  final SupplementResponse supplement;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: _image(),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplement.name,
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
                                color: AppColors.cyan,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                                border: Border.all(
                                  color: AppColors.cyan.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.plus,
                                color: AppColors.cyan,
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
      color: AppColors.surface,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textDark, size: 24),
      ),
    );
  }
}
