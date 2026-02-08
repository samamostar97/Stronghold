import 'dart:math';
import 'package:flutter/material.dart';

class RingProgress extends StatefulWidget {
  final double percentage;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const RingProgress({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 60,
    this.strokeWidth = 5,
    this.centerChild,
  });

  @override
  State<RingProgress> createState() => _RingProgressState();
}

class _RingProgressState extends State<RingProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(RingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            percentage: _animation.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
          child: Center(child: widget.centerChild),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * pi * (percentage / 100).clamp(0.0, 1.0);
    canvas.drawArc(rect, -pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.color != color;
}
