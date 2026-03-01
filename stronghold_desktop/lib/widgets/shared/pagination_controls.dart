import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final safeTotalPages = totalPages < 1 ? 1 : totalPages;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          '$totalCount stavki · Stranica $currentPage / $safeTotalPages',
          style: AppTextStyles.caption,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaginationButton(
              text: 'Prev',
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            const SizedBox(width: 6),
            ..._buildPageButtons(safeTotalPages),
            const SizedBox(width: 6),
            _PaginationButton(
              text: 'Next',
              enabled: currentPage < safeTotalPages,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageButtons(int safeTotalPages) {
    final result = <Widget>[];

    final start = (currentPage - 1).clamp(1, safeTotalPages);
    final end = (start + 2).clamp(1, safeTotalPages);
    final adjustedStart = (end - 2).clamp(1, safeTotalPages);

    for (var i = adjustedStart; i <= end; i++) {
      result.add(
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: _PaginationButton(
            text: '$i',
            enabled: true,
            isActive: i == currentPage,
            onTap: () => onPageChanged(i),
          ),
        ),
      );
    }

    return result;
  }
}

class _PaginationButton extends StatefulWidget {
  const _PaginationButton({
    required this.text,
    required this.enabled,
    required this.onTap,
    this.isActive = false,
  });

  final String text;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? AppColors.primary
        : (_hover && widget.enabled
              ? AppColors.surfaceHover
              : AppColors.surface);

    final border = widget.isActive ? AppColors.primary : AppColors.border;

    final textColor = widget.isActive
        ? Colors.white
        : (widget.enabled ? AppColors.textSecondary : AppColors.textMuted);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: border),
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
