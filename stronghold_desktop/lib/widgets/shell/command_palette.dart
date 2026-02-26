import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';
import '../../providers/command_palette_provider.dart';

/// Shows the command palette dialog overlay.
void showCommandPalette(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => const _CommandPaletteOverlay(),
  );
}

class _CommandPaletteOverlay extends ConsumerStatefulWidget {
  const _CommandPaletteOverlay();

  @override
  ConsumerState<_CommandPaletteOverlay> createState() =>
      _CommandPaletteOverlayState();
}

class _CommandPaletteOverlayState
    extends ConsumerState<_CommandPaletteOverlay> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commandPaletteProvider.notifier).open();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    ref
        .read(commandPaletteProvider.notifier)
        .updateQuery(_searchController.text);
  }

  void _close() {
    Navigator.of(context).pop();
    ref.read(commandPaletteProvider.notifier).close();
  }

  void _executeSelected() {
    final entry =
        ref.read(commandPaletteProvider.notifier).getSelectedEntry();
    if (entry == null) return;
    _close();
    if (entry.path != null) {
      context.go(entry.path!);
    } else if (entry.action != null) {
      entry.action!();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    final notifier = ref.read(commandPaletteProvider.notifier);
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      notifier.moveSelection(1);
      _ensureVisible();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      notifier.moveSelection(-1);
      _ensureVisible();
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _executeSelected();
    }
  }

  void _ensureVisible() {
    final state = ref.read(commandPaletteProvider);
    if (state.filteredResults.isEmpty) return;
    const itemHeight = 48.0;
    final targetOffset = state.selectedIndex * itemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;
    if (targetOffset < currentOffset) {
      _scrollController.animateTo(targetOffset,
          duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    } else if (targetOffset + itemHeight > currentOffset + viewportHeight) {
      _scrollController.animateTo(
          targetOffset + itemHeight - viewportHeight,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandPaletteProvider);
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: _close,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: AppColors.deepBlue.withOpacity(0.3),
            alignment: const Alignment(0, -0.3),
            child: GestureDetector(
              onTap: () {},
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: 560,
                  constraints: const BoxConstraints(maxHeight: 460),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.cardRadius,
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadowStrong,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _searchField(),
                      Container(height: 1, color: AppColors.borderLight),
                      if (state.filteredResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text('Nema rezultata',
                              style: AppTextStyles.bodySecondary.copyWith(
                                  color: AppColors.textMuted)),
                        )
                      else
                        _resultsList(state),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.sm),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Pretrazi stranice i akcije...',
          hintStyle: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textMuted),
          prefixIcon: const Icon(LucideIcons.search,
              color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _resultsList(CommandPaletteState state) {
    return Flexible(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        shrinkWrap: true,
        itemCount: state.filteredResults.length,
        itemBuilder: (context, index) {
          final entry = state.filteredResults[index];
          return _CommandResultItem(
            entry: entry,
            isSelected: index == state.selectedIndex,
            onTap: () {
              _close();
              if (entry.path != null) context.go(entry.path!);
            },
            onHover: () => ref
                .read(commandPaletteProvider.notifier)
                .moveSelection(index - state.selectedIndex),
          );
        },
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          const _KeyHint(label: 'Enter'),
          const SizedBox(width: AppSpacing.xs),
          Text('otvori', style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.base),
          const _KeyHint(label: 'Esc'),
          const SizedBox(width: AppSpacing.xs),
          Text('zatvori', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _CommandResultItem extends StatelessWidget {
  const _CommandResultItem({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onHover,
  });

  final CommandEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 1),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electric.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: AppSpacing.badgeRadius,
          ),
          child: Row(
            children: [
              Icon(entry.icon,
                  color: isSelected
                      ? AppColors.electric
                      : AppColors.textMuted,
                  size: 18),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Text(entry.label,
                    style: isSelected
                        ? AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.electric)
                        : AppTextStyles.bodySecondary),
              ),
              Text(entry.sublabel, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppSpacing.tinyRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: AppTextStyles.badge.copyWith(color: AppColors.textMuted)),
    );
  }
}
