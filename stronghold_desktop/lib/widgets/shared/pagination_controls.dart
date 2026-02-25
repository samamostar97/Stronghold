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
    return Column(
      children: [
        Text(
          'Ukupno: $totalCount | Stranica $currentPage od $totalPages',
          style: AppTextStyles.bodySm,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PaginationButton(
              text: '\u2190',
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            const SizedBox(width: AppSpacing.sm),
            ..._buildPageNumbers(),
            const SizedBox(width: AppSpacing.sm),
            PaginationButton(
              text: '\u2192',
              enabled: currentPage < totalPages,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageButtons = [];

    if (currentPage > 3) {
      pageButtons.add(PaginationButton(
        text: '1', enabled: true, onTap: () => onPageChanged(1),
      ));
      if (currentPage > 4) {
        pageButtons.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('...', style: AppTextStyles.bodySm),
        ));
      }
      pageButtons.add(const SizedBox(width: AppSpacing.xs));
    }

    for (int i = currentPage - 2; i <= currentPage + 2; i++) {
      if (i >= 1 && i <= totalPages) {
        pageButtons.add(PaginationButton(
          text: i.toString(),
          enabled: true,
          isActive: i == currentPage,
          onTap: () => onPageChanged(i),
        ));
        if (i < currentPage + 2 && i < totalPages) {
          pageButtons.add(const SizedBox(width: AppSpacing.xs));
        }
      }
    }

    if (currentPage < totalPages - 2) {
      pageButtons.add(const SizedBox(width: AppSpacing.xs));
      if (currentPage < totalPages - 3) {
        pageButtons.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('...', style: AppTextStyles.bodySm),
        ));
      }
      pageButtons.add(PaginationButton(
        text: totalPages.toString(),
        enabled: true,
        onTap: () => onPageChanged(totalPages),
      ));
    }

    return pageButtons;
  }
}

class PaginationButton extends StatefulWidget {
  const PaginationButton({
    super.key,
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
  State<PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<PaginationButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary
                : widget.enabled && _hover
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.enabled
                  ? AppColors.border
                  : AppColors.textMuted.withValues(alpha: 0.3),
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.bodyMd.copyWith(
              color: widget.isActive
                  ? AppColors.background
                  : widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textMuted.withValues(alpha: 0.5),
              fontWeight:
                  widget.isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
