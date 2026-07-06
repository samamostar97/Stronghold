import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

enum StatusTone { success, warning, danger, neutral, info }

/// Jedinstven prikaz statusa: tinted pozadina + tacka + tekst.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusChip({super.key, required this.label, required this.tone});

  Color get _color => switch (tone) {
        StatusTone.success => AppTheme.success,
        StatusTone.warning => AppTheme.warning,
        StatusTone.danger => AppTheme.danger,
        StatusTone.info => AppTheme.navy,
        StatusTone.neutral => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _color,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
