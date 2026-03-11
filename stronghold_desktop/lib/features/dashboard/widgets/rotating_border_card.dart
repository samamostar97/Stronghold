import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RotatingBorderCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const RotatingBorderCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<RotatingBorderCard> createState() => _RotatingBorderCardState();
}

class _RotatingBorderCardState extends State<RotatingBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RotatingBorderPainter(
                progress: _controller.value,
                hovering: _hovering,
              ),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sidebar,
              borderRadius: BorderRadius.circular(14),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double progress;
  final bool hovering;

  _RotatingBorderPainter({
    required this.progress,
    required this.hovering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    final angle = progress * 2 * pi;

    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: angle,
      endAngle: angle + 2 * pi,
      colors: [
        AppColors.primary.withValues(alpha: hovering ? 0.8 : 0.4),
        Colors.transparent,
        Colors.transparent,
        AppColors.primary.withValues(alpha: hovering ? 0.5 : 0.2),
        AppColors.primary.withValues(alpha: hovering ? 0.8 : 0.4),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = hovering ? 1.8 : 1.2;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RotatingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.hovering != hovering;
}
