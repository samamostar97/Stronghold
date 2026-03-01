import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

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
        style: AppTextStyles.tableHeader,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

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
        style: bold
            ? AppTextStyles.bodyMedium
            : (muted ? AppTextStyles.caption : AppTextStyles.bodySecondary),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

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
  final Widget Function(BuildContext context, int index) itemBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.panelRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.panelRadius,
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: AppSpacing.buttonRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          LucideIcons.inbox,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(emptyMessage, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Podesi filtere ili dodaj novi zapis.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: itemBuilder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HoverableTableRow extends StatefulWidget {
  const HoverableTableRow({
    super.key,
    required this.child,
    this.isLast = false,
    this.index,
    this.activeAccentColor,
    this.onTap,
  });

  final Widget child;
  final bool isLast;
  final int? index;
  final Color? activeAccentColor;
  final VoidCallback? onTap;

  @override
  State<HoverableTableRow> createState() => _HoverableTableRowState();
}

class _HoverableTableRowState extends State<HoverableTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeAccentColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hover ? AppColors.surfaceHover : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 2,
                height: 18,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _hover ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 11,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}

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

class ColumnDef<T> {
  const ColumnDef({
    required this.label,
    required this.flex,
    required this.cellBuilder,
    this.alignRight = false,
  });

  final String label;
  final int flex;
  final bool alignRight;
  final Widget Function(T item) cellBuilder;

  static ColumnDef<T> text<T>({
    required String label,
    required int flex,
    required String Function(T item) value,
    bool bold = false,
    bool Function(T item)? muted,
  }) {
    return ColumnDef<T>(
      label: label,
      flex: flex,
      cellBuilder: (item) {
        final isMuted = muted?.call(item) ?? false;
        return Text(
          value(item),
          style: bold
              ? AppTextStyles.bodyMedium
              : (isMuted ? AppTextStyles.caption : AppTextStyles.bodySecondary),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  static ColumnDef<T> actions<T>({
    int flex = 2,
    required List<Widget> Function(T item) builder,
  }) {
    return ColumnDef<T>(
      label: 'Akcije',
      flex: flex,
      alignRight: true,
      cellBuilder: (item) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: builder(item),
        ),
      ),
    );
  }
}

class GenericDataTable<T> extends StatelessWidget {
  const GenericDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.emptyMessage = 'Nema rezultata.',
    this.onRowTap,
  });

  final List<T> items;
  final List<ColumnDef<T>> columns;
  final String emptyMessage;
  final void Function(T item)? onRowTap;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: Row(
          children: columns
              .map(
                (col) => TableHeaderCell(
                  text: col.label,
                  flex: col.flex,
                  alignRight: col.alignRight,
                ),
              )
              .toList(),
        ),
      ),
      emptyMessage: emptyMessage,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return HoverableTableRow(
          index: i,
          isLast: i == items.length - 1,
          onTap: onRowTap == null ? null : () => onRowTap!(item),
          child: Row(
            children: columns
                .map(
                  (col) =>
                      Expanded(flex: col.flex, child: col.cellBuilder(item)),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
