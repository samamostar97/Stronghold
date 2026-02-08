import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
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
    // Autofocus after build
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

  void _executeSelected() {
    final entry =
        ref.read(commandPaletteProvider.notifier).getSelectedEntry();
    if (entry == null) return;

    Navigator.of(context).pop();
    ref.read(commandPaletteProvider.notifier).close();

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

    final itemHeight = 48.0;
    final targetOffset = state.selectedIndex * itemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;

    if (targetOffset < currentOffset) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    } else if (targetOffset + itemHeight > currentOffset + viewportHeight) {
      _scrollController.animateTo(
        targetOffset + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandPaletteProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          ref.read(commandPaletteProvider.notifier).close();
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            alignment: const Alignment(0, -0.3),
            child: GestureDetector(
              onTap: () {}, // prevent tap-through
              child: Container(
                width: 560,
                constraints: const BoxConstraints(maxHeight: 460),
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                  boxShadow: AppShadows.elevatedShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Pretrazi stranice i akcije...',
                          hintStyle: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.muted,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),

                    // Results list
                    if (state.filteredResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nema rezultata',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          itemCount: state.filteredResults.length,
                          itemBuilder: (context, index) {
                            final entry = state.filteredResults[index];
                            final isSelected =
                                index == state.selectedIndex;

                            return _CommandResultItem(
                              entry: entry,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(commandPaletteProvider.notifier)
                                    .updateQuery('');
                                Navigator.of(context).pop();
                                ref
                                    .read(commandPaletteProvider.notifier)
                                    .close();
                                if (entry.screen != null) {
                                  widget.onNavigate(entry.screen!);
                                }
                              },
                              onHover: () {
                                // Update selection on hover
                                ref
                                    .read(commandPaletteProvider.notifier)
                                    .moveSelection(
                                        index - state.selectedIndex);
                              },
                            );
                          },
                        ),
                      ),

                    // Footer hint
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _KeyHint(label: 'Enter'),
                          const SizedBox(width: 4),
                          const Text(
                            'otvori',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _KeyHint(label: 'Esc'),
                          const SizedBox(width: 4),
                          const Text(
                            'zatvori',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            children: [
              Icon(
                entry.icon,
                color: isSelected ? AppColors.accent : AppColors.muted,
                size: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                entry.sublabel,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
