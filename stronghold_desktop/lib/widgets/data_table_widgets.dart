import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
  });

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            header,
            if (itemCount == 0)
              Expanded(
                child: Center(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
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
  });

  final Widget child;
  final bool isLast;

  @override
  State<HoverableTableRow> createState() => _HoverableTableRowState();
}

class _HoverableTableRowState extends State<HoverableTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: widget.child,
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
