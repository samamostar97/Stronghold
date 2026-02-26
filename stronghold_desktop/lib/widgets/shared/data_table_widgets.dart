import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

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
        style: AppTextStyles.label.copyWith(color: AppColors.deepBlue),
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
        style: bold
            ? AppTextStyles.bodyBold
            : (muted
                ? AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)
                : AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 80;
            return Column(
              children: [
                if (!compact) header,
                if (itemCount == 0)
                  Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.inbox,
                            size: 28, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(emptyMessage, style: AppTextStyles.bodyBold),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Pokusajte promijeniti filtere ili dodajte novi zapis',
                        style: AppTextStyles.bodySm,
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
            );
          },
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

  bool get _hasActiveAccent => widget.activeAccentColor != null;

  Color get _backgroundColor {
    if (_hover) return AppColors.surfaceHover;
    if (_hasActiveAccent) {
      return widget.activeAccentColor!.withValues(alpha: 0.04);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final showBar = _hover || _hasActiveAccent;
    final barColor = _hover ? null : widget.activeAccentColor;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius:
                _hover ? BorderRadius.circular(6) : BorderRadius.zero,
            border: widget.isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.border)),
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
                          colors: [AppColors.primary, AppColors.secondary],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: AppSpacing.lg),
                  child: widget.child,
                ),
              ),
            ],
          ),
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
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 14, horizontal: AppSpacing.lg),
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
