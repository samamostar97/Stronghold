import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_theme.dart';
import '../providers/command_palette_provider.dart';
import '../screens/admin_dashboard_screen.dart';

/// Shows the command palette dialog overlay.
void showCommandPalette(
  BuildContext context, {
  required void Function(AdminScreen) onNavigate,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => _CommandPaletteOverlay(onNavigate: onNavigate),
  );
}

class _CommandPaletteOverlay extends ConsumerStatefulWidget {
  const _CommandPaletteOverlay({required this.onNavigate});

  final void Function(AdminScreen) onNavigate;

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
    ref.read(commandPaletteProvider.notifier).open();
    _searchController.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (entry.screen != null) {
      widget.onNavigate(entry.screen!);
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
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            alignment: const Alignment(0, -0.3),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 560,
                constraints: const BoxConstraints(maxHeight: 460),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSolid.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6)),
                  boxShadow: AppShadows.elevatedShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _searchField(),
                    Container(height: 1,
                        color: AppColors.border.withValues(alpha: 0.5)),
                    if (state.filteredResults.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Text('Nema rezultata',
                            style: AppTextStyles.bodyMd.copyWith(
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
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Pretrazi stranice i akcije...',
          hintStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textMuted.withValues(alpha: 0.7)),
          prefixIcon: Icon(LucideIcons.search,
              color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
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
              if (entry.screen != null) widget.onNavigate(entry.screen!);
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
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          const _KeyHint(label: 'Enter'),
          const SizedBox(width: AppSpacing.xs),
          Text('otvori', style: AppTextStyles.bodySm),
          const SizedBox(width: AppSpacing.lg),
          const _KeyHint(label: 'Esc'),
          const SizedBox(width: AppSpacing.xs),
          Text('zatvori', style: AppTextStyles.bodySm),
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
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 1),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Icon(entry.icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 18),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(entry.label,
                    style: isSelected
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary)),
              ),
              Text(entry.sublabel, style: AppTextStyles.bodySm),
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
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(
          color: AppColors.textMuted)),
    );
  }
}
