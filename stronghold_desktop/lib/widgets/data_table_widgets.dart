import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

/// Reusable header cell for data tables
class TableHeaderCell extends StatelessWidget {
  const TableHeaderCell({
    super.key,
    required this.text,
    required this.flex,
    this.alignRight = false,
  });

  final String text;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

/// Reusable data cell for table rows
class TableDataCell extends StatelessWidget {
  const TableDataCell({
    super.key,
    required this.text,
    required this.flex,
    this.bold = false,
    this.muted = false,
  });

  final String text;
  final int flex;
  final bool bold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: muted ? AppColors.muted : AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Reusable table container with header and list
class DataTableContainer extends StatelessWidget {
  const DataTableContainer({
    super.key,
    required this.header,
    required this.itemCount,
    required this.itemBuilder,
    this.emptyMessage = 'Nema rezultata.',
  });

  final Widget header;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            header,
            if (itemCount == 0)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.muted.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          size: 36,
                          color: AppColors.muted.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pokusajte promijeniti filtere ili dodajte novi zapis',
                        style: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Hoverable table row wrapper
class HoverableTableRow extends StatefulWidget {
  const HoverableTableRow({
    super.key,
    required this.child,
    this.isLast = false,
    this.index,
    this.activeAccentColor,
  });

  final Widget child;
  final bool isLast;
  final int? index;

  /// When set, shows a persistent left accent bar in this color (e.g. green for active status).
  final Color? activeAccentColor;

  @override
  State<HoverableTableRow> createState() => _HoverableTableRowState();
}

class _HoverableTableRowState extends State<HoverableTableRow> {
  bool _hover = false;

  bool get _hasActiveAccent => widget.activeAccentColor != null;

  Color get _backgroundColor {
    if (_hover) return AppColors.surfaceHover;
    if (_hasActiveAccent) {
      return widget.activeAccentColor!.withValues(alpha: 0.04);
    }
    if (widget.index != null && widget.index!.isOdd) {
      return AppColors.panel.withValues(alpha: 0.15);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final showBar = _hover || _hasActiveAccent;
    final barColor = _hover
        ? null // use gradient on hover
        : widget.activeAccentColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: _hover ? BorderRadius.circular(6) : BorderRadius.zero,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: showBar ? 3 : 0,
              height: 32,
              decoration: BoxDecoration(
                color: barColor,
                gradient: _hover
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.accent, AppColors.accentLight],
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard table header container
class TableHeader extends StatelessWidget {
  const TableHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: child,
    );
  }
}

/// Responsive action buttons cell that scales down to fit
class TableActionCell extends StatelessWidget {
  const TableActionCell({
    super.key,
    required this.flex,
    required this.children,
  });

  final int flex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        ),
      ),
    );
  }
}
