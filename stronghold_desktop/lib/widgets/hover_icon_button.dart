import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class HoverIconButton extends StatefulWidget {
  const HoverIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.muted,
    this.hoverColor = Colors.white,
    this.size = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color hoverColor;
  final double size;
  final String? tooltip;

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0.0, _hover ? -2.0 : 0.0, 0.0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hover ? AppColors.panel : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            color: _hover ? widget.hoverColor : widget.color,
            size: widget.size,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
