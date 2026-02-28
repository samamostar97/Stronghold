import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/faq_provider.dart';

class SettingsFaqTab extends ConsumerStatefulWidget {
  const SettingsFaqTab({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onAdd;
  final void Function(FaqResponse) onEdit;
  final void Function(FaqResponse) onDelete;

  @override
  ConsumerState<SettingsFaqTab> createState() => _SettingsFaqTabState();
}

class _SettingsFaqTabState extends ConsumerState<SettingsFaqTab> {
  final Set<int> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqListProvider);

    if (state.isLoading && state.data == null) {
      return _buildShimmer();
    }

    if (state.error != null && state.data == null) {
      return _buildError(state.error!);
    }

    final items = state.items;
    if (items.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: _AddButton(onTap: widget.onAdd),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final faq = items[index];
              final isExpanded = _expandedIds.contains(faq.id);
              return _FaqTile(
                faq: faq,
                isExpanded: isExpanded,
                onToggle: () => setState(() {
                  if (isExpanded) {
                    _expandedIds.remove(faq.id);
                  } else {
                    _expandedIds.add(faq.id);
                  }
                }),
                onEdit: () => widget.onEdit(faq),
                onDelete: () => widget.onDelete(faq),
              )
                  .animate(delay: (60 * index).ms)
                  .fadeIn(duration: Motion.fast, curve: Motion.curve)
                  .slideX(begin: -0.02, end: 0, duration: Motion.fast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.shimmer,
                borderRadius: AppSpacing.panelRadius,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: AppColors.shimmerHighlight),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(error, style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () => ref.read(faqListProvider.notifier).refresh(),
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
          Icon(LucideIcons.helpCircle, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Nema FAQ stavki',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: widget.onAdd,
            child: Text('+ Dodaj prvo pitanje',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.electric)),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final FaqResponse faq;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.gentle,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.panelRadius,
          border: Border.all(
            color: widget.isExpanded
                ? AppColors.electric.withValues(alpha: 0.3)
                : _hovered
                    ? AppColors.electric.withValues(alpha: 0.2)
                    : AppColors.border,
          ),
          boxShadow: widget.isExpanded || _hovered
              ? AppColors.cardShadow
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            InkWell(
              onTap: widget.onToggle,
              borderRadius: AppSpacing.panelRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.base,
                ),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.25 : 0,
                      duration: Motion.fast,
                      child: Icon(LucideIcons.chevronRight,
                          size: 18, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: AppTextStyles.bodyBold,
                        maxLines: widget.isExpanded ? null : 2,
                        overflow: widget.isExpanded
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                    ),
                    if (_hovered || widget.isExpanded) ...[
                      const SizedBox(width: AppSpacing.sm),
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
            // Body
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg + 18 + AppSpacing.md,
                  0,
                  AppSpacing.lg,
                  AppSpacing.base,
                ),
                child: Text(
                  widget.faq.answer,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              crossFadeState: widget.isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Motion.fast,
              sizeCurve: Motion.gentle,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
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
                ? AppColors.electric.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: AppSpacing.buttonRadius,
            border: Border.all(
              color: _hovered
                  ? AppColors.electric.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.plus,
                  size: 16,
                  color:
                      _hovered ? AppColors.electric : AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Dodaj FAQ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      _hovered ? AppColors.electric : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
