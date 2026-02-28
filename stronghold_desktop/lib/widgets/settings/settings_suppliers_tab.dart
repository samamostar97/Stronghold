import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/supplier_provider.dart';

class SettingsSuppliersTab extends ConsumerWidget {
  const SettingsSuppliersTab({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onAdd;
  final void Function(SupplierResponse) onEdit;
  final void Function(SupplierResponse) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supplierListProvider);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 550
                ? 2
                : 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              ...items.asMap().entries.map((entry) => SizedBox(
                    width: (constraints.maxWidth -
                            AppSpacing.lg * 2 -
                            AppSpacing.lg * (crossCount - 1)) /
                        crossCount,
                    child: _SupplierCard(
                      supplier: entry.value,
                      onEdit: () => onEdit(entry.value),
                      onDelete: () => onDelete(entry.value),
                    )
                        .animate(delay: (70 * entry.key).ms)
                        .fadeIn(duration: Motion.fast, curve: Motion.curve)
                        .slideY(begin: 0.06, end: 0, duration: Motion.fast),
                  )),
              SizedBox(
                width: (constraints.maxWidth -
                        AppSpacing.lg * 2 -
                        AppSpacing.lg * (crossCount - 1)) /
                    crossCount,
                child: _AddCard(onTap: onAdd)
                    .animate(delay: (70 * items.length).ms)
                    .fadeIn(duration: Motion.fast, curve: Motion.curve),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: List.generate(
          4,
          (i) => Container(
            width: 260,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: AppSpacing.cardRadius,
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
                ref.read(supplierListProvider.notifier).refresh(),
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
          Icon(LucideIcons.truck, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Nema dobavljaca',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onAdd,
            child: Text('+ Dodaj prvog dobavljaca',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.electric)),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatefulWidget {
  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplierResponse supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<_SupplierCard> {
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          transform: _hovered
              ? (Matrix4.identity()..translate(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.panelRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: _hovered ? AppColors.cardShadow : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electric.withValues(alpha: 0.08),
                  borderRadius: AppSpacing.badgeRadius,
                ),
                child: Icon(LucideIcons.truck,
                    size: 18, color: AppColors.electric),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.supplier.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.supplier.website?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.supplier.website!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (_hovered) ...[
                InkWell(
                  onTap: widget.onEdit,
                  borderRadius: AppSpacing.badgeRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(LucideIcons.pencil,
                        size: 16, color: AppColors.electric),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: AppSpacing.badgeRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(LucideIcons.trash2,
                        size: 16, color: AppColors.error),
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

class _AddCard extends StatefulWidget {
  const _AddCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<_AddCard> {
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
          height: 80,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.electric.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: AppSpacing.panelRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.textMuted.withValues(alpha: 0.3),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.plus,
                    size: 18,
                    color: _hovered
                        ? AppColors.electric
                        : AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Dodaj dobavljaca',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _hovered
                        ? AppColors.electric
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
