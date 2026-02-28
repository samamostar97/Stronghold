import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/supplement_category_provider.dart';

class SettingsCategoriesTab extends ConsumerWidget {
  const SettingsCategoriesTab({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onAdd;
  final void Function(SupplementCategoryResponse) onEdit;
  final void Function(SupplementCategoryResponse) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supplementCategoryListProvider);

    if (state.isLoading && state.data == null) {
      return _buildShimmer();
    }

    if (state.error != null && state.data == null) {
      return _buildError(state.error!, ref);
    }

    final items = state.items;
    if (items.isEmpty) {
      return _buildEmpty();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          ...items.asMap().entries.map((entry) => _CategoryChip(
                category: entry.value,
                onEdit: () => onEdit(entry.value),
                onDelete: () => onDelete(entry.value),
              )
                  .animate(delay: (50 * entry.key).ms)
                  .fadeIn(duration: Motion.fast, curve: Motion.curve)
                  .scaleXY(begin: 0.92, end: 1, duration: Motion.fast)),
          _AddChip(onTap: onAdd)
              .animate(delay: (50 * items.length).ms)
              .fadeIn(duration: Motion.fast, curve: Motion.curve),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: List.generate(
          6,
          (i) => Container(
            width: 110,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: AppSpacing.chipRadius,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: AppColors.shimmerHighlight),
        ),
      ),
    );
  }

  Widget _buildError(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(error, style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () =>
                ref.read(supplementCategoryListProvider.notifier).refresh(),
            child: Text('Pokusaj ponovo',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.electric)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.tag, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Nema kategorija',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onAdd,
            child: Text('+ Dodaj prvu kategoriju',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.electric)),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementCategoryResponse category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onEdit,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.gentle,
          padding: EdgeInsets.only(
            left: AppSpacing.base,
            right: _hovered ? AppSpacing.sm : AppSpacing.base,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.electric.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: AppSpacing.chipRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: _hovered ? AppColors.cardShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.tag,
                  size: 14,
                  color: _hovered
                      ? AppColors.electric
                      : AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.category.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _hovered
                      ? AppColors.electric
                      : AppColors.textPrimary,
                ),
              ),
              if (_hovered) ...[
                const SizedBox(width: AppSpacing.sm),
                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: AppSpacing.tinyRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(LucideIcons.x,
                        size: 14, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatefulWidget {
  const _AddChip({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddChip> createState() => _AddChipState();
}

class _AddChipState extends State<_AddChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.gentle,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.electric.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: AppSpacing.chipRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.textMuted.withValues(alpha: 0.3),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.plus,
                  size: 14,
                  color:
                      _hovered ? AppColors.electric : AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Dodaj',
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      _hovered ? AppColors.electric : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
