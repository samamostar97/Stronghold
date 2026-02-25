import 'package:flutter/material.dart';

/// Colored pill badge for displaying entity status.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.textStyle,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;

  factory StatusPill.active() =>
      const StatusPill(label: 'Aktivan', color: Color(0xFF34D399));

  factory StatusPill.inactive() =>
      const StatusPill(label: 'Neaktivan', color: Color(0xFF64748B));

  factory StatusPill.expired() =>
      const StatusPill(label: 'Istekao', color: Color(0xFFFB7185));

  factory StatusPill.pending() =>
      const StatusPill(label: 'Na cekanju', color: Color(0xFFF59E0B));

  factory StatusPill.paid() =>
      const StatusPill(label: 'Placeno', color: Color(0xFF34D399));

  factory StatusPill.delivered() =>
      const StatusPill(label: 'Dostavljeno', color: Color(0xFF22D3EE));

  factory StatusPill.cancelled() =>
      const StatusPill(label: 'Otkazano', color: Color(0xFFFB7185));

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.33,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: style.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
