import 'package:flutter/material.dart';

/// Glass-morphism card with optional hover effects.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = const Color(0xFF131D32),
    this.borderColor = const Color(0x0DFFFFFF),
    this.hoverBorderColor = const Color(0x14FFFFFF),
    this.borderRadius = 16.0,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _hover && interactive
              ? widget.hoverBorderColor
              : widget.borderColor,
        ),
      ),
      child: widget.child,
    );

    if (interactive) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(onTap: widget.onTap, child: card),
      );
    }

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: card);
    }

    return card;
  }
}
