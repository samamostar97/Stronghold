import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/recommendation.dart';
import '../models/supplement_models.dart';
import '../providers/recommendation_provider.dart';
import '../screens/supplement_detail_screen.dart';
import '../utils/image_utils.dart';
import 'glass_card.dart';
import 'section_header.dart';

class HomeRecommendations extends ConsumerWidget {
  const HomeRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recs = ref.watch(defaultRecommendationsProvider);

    return recs.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Preporuceno za vas'),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) => _card(context, items[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _card(BuildContext context, Recommendation rec) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SupplementDetailScreen(
            supplement: Supplement(
              id: rec.id,
              name: rec.name,
              price: rec.price,
              description: rec.description,
              imageUrl: rec.imageUrl,
              categoryId: 0,
              categoryName: rec.categoryName,
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: 140,
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
                  height: 80,
                  width: double.infinity,
                  child: rec.imageUrl != null
                      ? Image.network(
                          getFullImageUrl(rec.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${rec.price.toStringAsFixed(2)} KM',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.primary, fontSize: 12),
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

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textDark, size: 24),
      ),
    );
  }
}
