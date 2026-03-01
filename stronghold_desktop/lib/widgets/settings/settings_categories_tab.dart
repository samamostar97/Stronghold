import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/list_state.dart';
import '../../providers/supplement_category_provider.dart';
import 'settings_tab_scaffold.dart';

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

    return SettingsTabScaffold(
      title: 'Kategorije suplemenata',
      subtitle: 'Organizuj proizvode kroz jasne kategorije',
      addLabel: '+ Dodaj kategoriju',
      onAdd: onAdd,
      child: _body(state, ref),
    );
  }

  Widget _body(
    ListState<SupplementCategoryResponse, SupplementCategoryQueryFilter> state,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.data == null) {
      return const SettingsSkeletonWrap(
        itemCount: 10,
        itemWidth: 180,
        itemHeight: 42,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
      );
    }

    if (state.error != null && state.data == null) {
      return SettingsStatePane(
        icon: LucideIcons.alertCircle,
        title: 'Greska pri ucitavanju',
        description: state.error!,
        actionLabel: 'Pokusaj ponovo',
        onAction: () =>
            ref.read(supplementCategoryListProvider.notifier).refresh(),
      );
    }

    final items = state.items;
    if (items.isEmpty) {
      return SettingsStatePane(
        icon: LucideIcons.tag,
        title: 'Nema kategorija',
        description:
            'Dodaj kategoriju da bi katalog suplemenata bio pregledniji.',
        actionLabel: '+ Dodaj kategoriju',
        onAction: onAdd,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: items.asMap().entries.map((entry) {
          return _CategoryChip(
                category: entry.value,
                onEdit: () => onEdit(entry.value),
                onDelete: () => onDelete(entry.value),
              )
              .animate(delay: (40 * entry.key).ms)
              .fadeIn(duration: Motion.fast, curve: Motion.curve)
              .scaleXY(begin: 0.96, end: 1, duration: Motion.fast);
        }).toList(),
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
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.gentle,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.primaryDim : AppColors.surface,
          borderRadius: AppSpacing.chipRadius,
          border: Border.all(
            color: _hovered ? AppColors.primaryBorder : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.tag,
              size: 14,
              color: _hovered ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.category.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _hovered ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ChipAction(
              icon: LucideIcons.pencil,
              color: AppColors.primary,
              tooltip: 'Izmijeni kategoriju',
              onTap: widget.onEdit,
            ),
            const SizedBox(width: AppSpacing.xs),
            _ChipAction(
              icon: LucideIcons.x,
              color: AppColors.error,
              tooltip: 'Obrisi kategoriju',
              onTap: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipAction extends StatelessWidget {
  const _ChipAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.tinyRadius,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
