import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Tier 2 — Table sort header with uppercase label and arrow indicator.
class SortHeader extends StatelessWidget {
  const SortHeader({
    super.key,
    required this.label,
    required this.field,
    required this.currentSortField,
    required this.sortDirection,
    required this.onTap,
  });

  final String label;
  final String field;
  final String? currentSortField;
  final String? sortDirection; // 'asc' or 'desc'
  final VoidCallback onTap;

  bool get _isActive => currentSortField == field;

  @override
  Widget build(BuildContext context) {
    final color = _isActive ? AppColors.primary : AppColors.textDark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.label.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (_isActive) ...[
              const SizedBox(width: 4),
              Icon(
                sortDirection == 'asc'
                    ? LucideIcons.arrowUp
                    : LucideIcons.arrowDown,
                size: 14,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
