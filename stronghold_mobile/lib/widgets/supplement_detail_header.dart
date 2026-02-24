import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';
import 'glass_card.dart';
import 'status_pill.dart';

class SupplementDetailHeader extends StatelessWidget {
  final SupplementResponse supplement;

  const SupplementDetailHeader({super.key, required this.supplement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: _image(),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(supplement.name, style: AppTextStyles.headingLg),
        const SizedBox(height: AppSpacing.sm),
        StatusPill(label: supplement.supplementCategoryName ?? '', color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${supplement.price.toStringAsFixed(2)} KM',
          style: AppTextStyles.stat.copyWith(color: AppColors.primary),
        ),
        if (supplement.description != null &&
            supplement.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text('Opis', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Text(
              supplement.description!,
              style: AppTextStyles.bodyMd.copyWith(height: 1.5),
            ),
          ),
        ],
      ],
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
      color: AppColors.surface,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textDark, size: 48),
      ),
    );
  }
}
