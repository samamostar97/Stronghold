import 'package:flutter/material.dart';

/// Floating card with border and glow shadow — Aether design system.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0x1F4F8EF7),
    this.hoverBorderColor = const Color(0x334F8EF7),
    this.borderRadius = 20.0,
    this.onTap,
    this.margin,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool showShadow;

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
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF4F8EF7).withOpacity(
                    _hover && interactive ? 0.18 : 0.12,
                  ),
                  blurRadius: _hover && interactive ? 48 : 40,
                  offset: Offset(0, _hover && interactive ? 12 : 8),
                ),
              ]
            : null,
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
