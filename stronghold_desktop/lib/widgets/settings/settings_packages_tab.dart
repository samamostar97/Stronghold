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
import '../../providers/membership_package_provider.dart';
import 'settings_tab_scaffold.dart';

class SettingsPackagesTab extends ConsumerWidget {
  const SettingsPackagesTab({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onAdd;
  final void Function(MembershipPackageResponse) onEdit;
  final void Function(MembershipPackageResponse) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membershipPackageListProvider);

    return SettingsTabScaffold(
      title: 'Paketi clanarina',
      subtitle: 'Definisi cijene i opis paketa dostupnih korisnicima',
      addLabel: '+ Dodaj paket',
      onAdd: onAdd,
      child: _body(state, ref),
    );
  }

  Widget _body(
    ListState<MembershipPackageResponse, MembershipPackageQueryFilter> state,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.data == null) {
      return const SettingsSkeletonWrap(
        itemCount: 4,
        itemWidth: 292,
        itemHeight: 182,
      );
    }

    if (state.error != null && state.data == null) {
      return SettingsStatePane(
        icon: LucideIcons.alertCircle,
        title: 'Greska pri ucitavanju',
        description: state.error!,
        actionLabel: 'Pokusaj ponovo',
        onAction: () =>
            ref.read(membershipPackageListProvider.notifier).refresh(),
      );
    }

    final items = state.items;
    if (items.isEmpty) {
      return SettingsStatePane(
        icon: LucideIcons.package2,
        title: 'Nema paketa clanarina',
        description:
            'Dodaj prvi paket kako bi korisnici mogli aktivirati clanarinu.',
        actionLabel: '+ Dodaj paket',
        onAction: onAdd,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: items.asMap().entries.map((entry) {
          return _PackageCard(
                package: entry.value,
                onEdit: () => onEdit(entry.value),
                onDelete: () => onDelete(entry.value),
              )
              .animate(delay: (80 * entry.key).ms)
              .fadeIn(duration: Motion.fast, curve: Motion.curve)
              .slideY(begin: 0.05, end: 0, duration: Motion.fast);
        }).toList(),
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  const _PackageCard({
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  final MembershipPackageResponse package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.gentle,
        width: 292,
        padding: const EdgeInsets.all(AppSpacing.xl),
        transform: _hovered
            ? Matrix4.translationValues(0.0, -2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: _hovered ? AppColors.primaryBorder : AppColors.border,
          ),
          boxShadow: _hovered
              ? AppColors.cardShadowStrong
              : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.package.packageName ?? '-',
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _IconBtn(
                  icon: LucideIcons.pencil,
                  color: AppColors.primary,
                  tooltip: 'Izmijeni paket',
                  onTap: widget.onEdit,
                ),
                const SizedBox(width: AppSpacing.xs),
                _IconBtn(
                  icon: LucideIcons.trash2,
                  color: AppColors.error,
                  tooltip: 'Obrisi paket',
                  onTap: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              '${widget.package.packagePrice.toStringAsFixed(2)} KM',
              style: AppTextStyles.metricMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            if (widget.package.description?.isNotEmpty == true) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.package.description!,
                style: AppTextStyles.bodySecondary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
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
