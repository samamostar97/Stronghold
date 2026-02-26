import 'package:flutter/material.dart';

/// Colored pill badge for displaying entity status — Aether design.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.textStyle,
    this.glowing = false,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;
  final bool glowing;

  factory StatusPill.active() =>
      const StatusPill(label: 'Aktivan', color: Color(0xFF22D3A7), glowing: true);

  factory StatusPill.inactive() =>
      const StatusPill(label: 'Neaktivan', color: Color(0xFF9AAFC4));

  factory StatusPill.expired() =>
      const StatusPill(label: 'Istekao', color: Color(0xFFFB7185));

  factory StatusPill.pending() =>
      const StatusPill(label: 'Na cekanju', color: Color(0xFFFBBF24));

  factory StatusPill.paid() =>
      const StatusPill(label: 'Placeno', color: Color(0xFF22D3A7), glowing: true);

  factory StatusPill.delivered() =>
      const StatusPill(label: 'Dostavljeno', color: Color(0xFF4F8EF7));

  factory StatusPill.cancelled() =>
      const StatusPill(label: 'Otkazano', color: Color(0xFFFB7185));

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.33,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: glowing
                    ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)]
                    : null,
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
