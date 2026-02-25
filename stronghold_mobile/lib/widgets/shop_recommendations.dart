import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';
import 'section_header.dart';

class ShopRecommendations extends StatelessWidget {
  final List<RecommendationResponse> items;

  const ShopRecommendations({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: 'Preporuceno za tebe'),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) => _card(context, items[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Text(
            'Svi suplementi',
            style: AppTextStyles.headingSm
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _card(BuildContext context, RecommendationResponse rec) {
    return GestureDetector(
      onTap: () => context.push('/shop/detail', extra: SupplementResponse(
        id: rec.id,
        name: rec.name,
        price: rec.price,
        description: rec.description,
        imageUrl: rec.imageUrl,
        supplementCategoryId: 0,
        supplementCategoryName: rec.categoryName,
        supplierId: 0,
      )),
      child: SizedBox(
        width: 150,
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: rec.imageUrl != null
                      ? Image.network(
                          getFullImageUrl(rec.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.name,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [
                      const Icon(LucideIcons.star,
                          color: AppColors.warning, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        rec.averageRating.toStringAsFixed(1),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Text(' (${rec.reviewCount})',
                          style: AppTextStyles.caption),
                    ]),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${rec.price.toStringAsFixed(2)} KM',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
