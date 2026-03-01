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
import '../../providers/supplier_provider.dart';
import 'settings_tab_scaffold.dart';

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

    return SettingsTabScaffold(
      title: 'Dobavljaci',
      subtitle: 'Upravljanje partnerima i izvorima nabavke',
      addLabel: '+ Dodaj dobavljaca',
      onAdd: onAdd,
      child: _body(state, ref),
    );
  }

  Widget _body(
    ListState<SupplierResponse, SupplierQueryFilter> state,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.data == null) {
      return const SettingsSkeletonWrap(
        itemCount: 6,
        itemWidth: 280,
        itemHeight: 104,
      );
    }

    if (state.error != null && state.data == null) {
      return SettingsStatePane(
        icon: LucideIcons.alertCircle,
        title: 'Greska pri ucitavanju',
        description: state.error!,
        actionLabel: 'Pokusaj ponovo',
        onAction: () => ref.read(supplierListProvider.notifier).refresh(),
      );
    }

    final items = state.items;
    if (items.isEmpty) {
      return SettingsStatePane(
        icon: LucideIcons.truck,
        title: 'Nema dobavljaca',
        description:
            'Dodaj prvog dobavljaca kako bi katalog bio spreman za nabavku.',
        actionLabel: '+ Dodaj dobavljaca',
        onAction: onAdd,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1020
            ? 3
            : constraints.maxWidth > 680
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - AppSpacing.lg * (crossCount + 1)) /
            crossCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: items.asMap().entries.map((entry) {
              return SizedBox(
                width: itemWidth,
                child:
                    _SupplierCard(
                          supplier: entry.value,
                          onEdit: () => onEdit(entry.value),
                          onDelete: () => onDelete(entry.value),
                        )
                        .animate(delay: (60 * entry.key).ms)
                        .fadeIn(duration: Motion.fast, curve: Motion.curve)
                        .slideY(begin: 0.05, end: 0, duration: Motion.fast),
              );
            }).toList(),
          ),
        );
      },
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
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.gentle,
        padding: const EdgeInsets.all(AppSpacing.lg),
        transform: _hovered
            ? Matrix4.translationValues(0.0, -2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.panelRadius,
          border: Border.all(
            color: _hovered ? AppColors.primaryBorder : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.cardShadow : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: AppSpacing.badgeRadius,
              ),
              child: const Icon(
                LucideIcons.truck,
                size: 18,
                color: AppColors.primary,
              ),
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
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            _SupplierAction(
              icon: LucideIcons.pencil,
              color: AppColors.primary,
              tooltip: 'Izmijeni dobavljaca',
              onTap: widget.onEdit,
            ),
            const SizedBox(width: AppSpacing.xs),
            _SupplierAction(
              icon: LucideIcons.trash2,
              color: AppColors.error,
              tooltip: 'Obrisi dobavljaca',
              onTap: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierAction extends StatelessWidget {
  const _SupplierAction({
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
        borderRadius: AppSpacing.badgeRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
