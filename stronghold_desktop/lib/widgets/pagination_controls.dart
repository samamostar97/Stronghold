import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

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
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PaginationButton(
              text: '\u2190',
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
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

    // Show first page
    if (currentPage > 3) {
      pageButtons.add(PaginationButton(
        text: '1',
        enabled: true,
        isActive: false,
        onTap: () => onPageChanged(1),
      ));
      if (currentPage > 4) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: AppColors.muted)),
        ));
      }
      pageButtons.add(const SizedBox(width: 4));
    }

    // Show pages around current page
    for (int i = currentPage - 2; i <= currentPage + 2; i++) {
      if (i >= 1 && i <= totalPages) {
        pageButtons.add(PaginationButton(
          text: i.toString(),
          enabled: true,
          isActive: i == currentPage,
          onTap: () => onPageChanged(i),
        ));
        if (i < currentPage + 2 && i < totalPages) {
          pageButtons.add(const SizedBox(width: 4));
        }
      }
    }

    // Show last page
    if (currentPage < totalPages - 2) {
      pageButtons.add(const SizedBox(width: 4));
      if (currentPage < totalPages - 3) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: AppColors.muted)),
        ));
      }
      pageButtons.add(PaginationButton(
        text: totalPages.toString(),
        enabled: true,
        isActive: false,
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
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent
                : widget.enabled && _hover
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.enabled ? AppColors.border : AppColors.muted.withValues(alpha: 0.3),
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.enabled ? Colors.white : AppColors.muted.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
