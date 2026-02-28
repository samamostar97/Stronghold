import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/membership_package_provider.dart';

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
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          ...items.asMap().entries.map((entry) => _PackageCard(
                package: entry.value,
                onEdit: () => onEdit(entry.value),
                onDelete: () => onDelete(entry.value),
              )
                  .animate(delay: (80 * entry.key).ms)
                  .fadeIn(duration: Motion.fast, curve: Motion.curve)
                  .slideY(begin: 0.06, end: 0, duration: Motion.fast)),
          _AddCard(onTap: onAdd)
              .animate(delay: (80 * items.length).ms)
              .fadeIn(duration: Motion.fast, curve: Motion.curve),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: List.generate(
          3,
          (i) => Container(
            width: 280,
            height: 180,
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
                ref.read(membershipPackageListProvider.notifier).refresh(),
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
          Icon(LucideIcons.package2, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Nema paketa clanarina',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onAdd,
            child: Text('+ Dodaj prvi paket',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.electric)),
          ),
        ],
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
      child: GestureDetector(
        onTap: widget.onEdit,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.gentle,
          width: 280,
          padding: const EdgeInsets.all(AppSpacing.xl),
          transform: _hovered
              ? (Matrix4.identity()..translate(0.0, -4.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: _hovered ? AppColors.cardShadowStrong : AppColors.cardShadow,
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
                  if (_hovered) ...[
                    _IconBtn(
                      icon: LucideIcons.pencil,
                      color: AppColors.electric,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _IconBtn(
                      icon: LucideIcons.trash2,
                      color: AppColors.error,
                      onTap: widget.onDelete,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                '${widget.package.packagePrice.toStringAsFixed(2)} KM',
                style: AppTextStyles.metricMedium
                    .copyWith(color: AppColors.electric),
              ),
              if (widget.package.description?.isNotEmpty == true) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.package.description!,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
          width: 280,
          height: 180,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.electric.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.textMuted.withValues(alpha: 0.3),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.plus,
                    size: 28,
                    color: _hovered
                        ? AppColors.electric
                        : AppColors.textMuted),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Dodaj paket',
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.badgeRadius,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
