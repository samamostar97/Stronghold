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
import '../../providers/list_state.dart';
import 'settings_tab_scaffold.dart';

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

    return SettingsTabScaffold(
      title: 'FAQ',
      subtitle: 'Najcesca pitanja i odgovori za korisnike aplikacije',
      addLabel: '+ Dodaj FAQ',
      onAdd: widget.onAdd,
      child: _body(state),
    );
  }

  Widget _body(ListState<FaqResponse, FaqQueryFilter> state) {
    if (state.isLoading && state.data == null) {
      return const SettingsSkeletonList(itemCount: 5, itemHeight: 60);
    }

    if (state.error != null && state.data == null) {
      return SettingsStatePane(
        icon: LucideIcons.alertCircle,
        title: 'Greska pri ucitavanju',
        description: state.error!,
        actionLabel: 'Pokusaj ponovo',
        onAction: () => ref.read(faqListProvider.notifier).refresh(),
      );
    }

    final items = state.items;
    if (items.isEmpty) {
      return SettingsStatePane(
        icon: LucideIcons.helpCircle,
        title: 'Nema FAQ stavki',
        description: 'Dodaj prvo pitanje da olaksas korisnicima snalazenje.',
        actionLabel: '+ Dodaj FAQ',
        onAction: widget.onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
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
            .animate(delay: (50 * index).ms)
            .fadeIn(duration: Motion.fast, curve: Motion.curve)
            .slideY(begin: 0.04, end: 0, duration: Motion.fast);
      },
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
            color: widget.isExpanded || _hovered
                ? AppColors.primaryBorder
                : AppColors.border,
          ),
          boxShadow: widget.isExpanded || _hovered
              ? AppColors.cardShadow
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      child: const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
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
                    const SizedBox(width: AppSpacing.sm),
                    _FaqAction(
                      icon: LucideIcons.pencil,
                      tooltip: 'Izmijeni FAQ',
                      color: AppColors.primary,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FaqAction(
                      icon: LucideIcons.trash2,
                      tooltip: 'Obrisi FAQ',
                      color: AppColors.error,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
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
                  style: AppTextStyles.bodySecondary,
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

class _FaqAction extends StatelessWidget {
  const _FaqAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
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
