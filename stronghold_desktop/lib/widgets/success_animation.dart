import 'package:flutter/material.dart';

/// A reusable success animation widget that displays an animated green checkmark
/// in a circular container with a glow effect.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.black.withValues(alpha: 0.3),
///   barrierDismissible: false,
///   builder: (context) => const SuccessAnimation(),
/// );
///
/// // Auto-dismiss after delay
/// Future.delayed(const Duration(milliseconds: 1500), () {
///   Navigator.of(context).pop();
/// });
/// ```
class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({super.key});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: CheckmarkPainter(progress: _checkAnimation.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final checkPath = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Start point (left part of checkmark)
    final startX = center.dx - 20;
    final startY = center.dy;

    // Middle point (bottom of checkmark)
    final midX = center.dx - 5;
    final midY = center.dy + 15;

    // End point (right part of checkmark)
    final endX = center.dx + 25;
    final endY = center.dy - 15;

    checkPath.moveTo(startX, startY);

    if (progress < 0.5) {
      // Draw first part of checkmark (down)
      final t = progress * 2;
      checkPath.lineTo(
        startX + (midX - startX) * t,
        startY + (midY - startY) * t,
      );
    } else {
      // Complete first part and draw second part (up)
      checkPath.lineTo(midX, midY);
      final t = (progress - 0.5) * 2;
      checkPath.lineTo(
        midX + (endX - midX) * t,
        midY + (endY - midY) * t,
      );
    }

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Helper function to show the success animation dialog
void showSuccessAnimation(BuildContext context, {int durationMs = 1500}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    barrierDismissible: false,
    builder: (context) => const SuccessAnimation(),
  );

  Future.delayed(Duration(milliseconds: durationMs), () {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  });
}
