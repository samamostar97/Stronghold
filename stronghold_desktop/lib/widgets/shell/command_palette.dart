import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/command_palette_provider.dart';

void showCommandPalette(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: AppColors.overlay,
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
  final _searchFocus = FocusNode();
  final _keyboardFocus = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commandPaletteProvider.notifier).open();
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _keyboardFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    ref
        .read(commandPaletteProvider.notifier)
        .updateQuery(_searchController.text);
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(commandPaletteProvider.notifier).close();
  }

  void _executeSelected() {
    final entry = ref.read(commandPaletteProvider.notifier).getSelectedEntry();
    if (entry == null) return;

    _close();
    if (!mounted) return;

    if (entry.path != null) {
      context.go(entry.path!);
    } else {
      entry.action?.call();
    }
  }

  void _ensureVisible() {
    final state = ref.read(commandPaletteProvider);
    if (state.filteredResults.isEmpty || !_scrollController.hasClients) return;

    const itemHeight = 52.0;
    final target = state.selectedIndex * itemHeight;
    final viewport = _scrollController.position.viewportDimension;
    final current = _scrollController.offset;

    if (target < current) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
      );
    } else if (target + itemHeight > current + viewport) {
      _scrollController.animateTo(
        target + itemHeight - viewport,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    final notifier = ref.read(commandPaletteProvider.notifier);

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      notifier.moveSelection(1);
      _ensureVisible();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      notifier.moveSelection(-1);
      _ensureVisible();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _executeSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandPaletteProvider);

    return Material(
      type: MaterialType.transparency,
      child: KeyboardListener(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: GestureDetector(
          onTap: _close,
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 320,
                    maxWidth: 620,
                    minHeight: 220,
                    maxHeight: 500,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.cardRadius,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadowStrong,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _header(),
                        const Divider(height: 1, color: AppColors.borderLight),
                        Expanded(
                          child: state.filteredResults.isEmpty
                              ? _empty()
                              : _results(state),
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Pretrazi ekrane i komande...',
          hintStyle: AppTextStyles.bodySecondary,
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 16,
            color: AppColors.textMuted,
          ),
          suffixIcon: IconButton(
            onPressed: _close,
            icon: const Icon(
              LucideIcons.x,
              size: 16,
              color: AppColors.textMuted,
            ),
            tooltip: 'Zatvori',
          ),
        ),
      ),
    );
  }

  Widget _results(CommandPaletteState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.filteredResults.length,
      itemBuilder: (context, index) {
        final entry = state.filteredResults[index];
        final selected = index == state.selectedIndex;

        return _ResultRow(
          entry: entry,
          selected: selected,
          onHover: () {
            final delta = index - state.selectedIndex;
            if (delta != 0) {
              ref.read(commandPaletteProvider.notifier).moveSelection(delta);
            }
          },
          onTap: () {
            _close();
            if (!mounted) return;
            if (entry.path != null) {
              context.go(entry.path!);
            } else {
              entry.action?.call();
            }
          },
        );
      },
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: AppSpacing.buttonRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              LucideIcons.searchX,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text('Nema rezultata', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text(
            'Promijeni upit i pokusaj ponovo.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const _KeyHint(label: 'Enter'),
          const SizedBox(width: 6),
          Text('otvori', style: AppTextStyles.caption),
          const SizedBox(width: 12),
          const _KeyHint(label: '? ?'),
          const SizedBox(width: 6),
          Text('kretanje', style: AppTextStyles.caption),
          const SizedBox(width: 12),
          const _KeyHint(label: 'Esc'),
          const SizedBox(width: 6),
          Text('zatvori', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ResultRow extends StatefulWidget {
  const _ResultRow({
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  final CommandEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<_ResultRow> createState() => _ResultRowState();
}

class _ResultRowState extends State<_ResultRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryDim : Colors.transparent,
            borderRadius: AppSpacing.smallRadius,
            border: Border.all(
              color: active ? AppColors.primaryBorder : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : AppColors.surfaceAlt,
                  borderRadius: AppSpacing.tinyRadius,
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.entry.icon,
                  size: 14,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.entry.label,
                  style: active
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        )
                      : AppTextStyles.bodySecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.entry.sublabel, style: AppTextStyles.caption),
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
        color: AppColors.surfaceAlt,
        borderRadius: AppSpacing.tinyRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.badge),
    );
  }
}
