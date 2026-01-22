import 'package:flutter/material.dart';

/// A reusable error animation widget that displays an animated red X
/// in a circular container with an error message.
///
/// Usage:
/// ```dart
/// showErrorAnimation(
///   context,
///   message: 'Check-out neuspješan',
/// );
/// ```
class ErrorAnimation extends StatefulWidget {
  final String message;

  const ErrorAnimation({
    super.key,
    required this.message,
  });

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _xAnimation;

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

    _xAnimation = CurvedAnimation(
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated X in circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5757),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5757).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _xAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: XMarkPainter(progress: _xAnimation.value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5757),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'U redu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class XMarkPainter extends CustomPainter {
  final double progress;

  XMarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0;

    // First line of X (top-left to bottom-right)
    if (progress < 0.5) {
      final t = progress * 2;
      final path1 = Path();
      path1.moveTo(center.dx - radius, center.dy - radius);
      path1.lineTo(
        center.dx - radius + (radius * 2 * t),
        center.dy - radius + (radius * 2 * t),
      );
      canvas.drawPath(path1, paint);
    } else {
      // Complete first line
      final path1 = Path();
      path1.moveTo(center.dx - radius, center.dy - radius);
      path1.lineTo(center.dx + radius, center.dy + radius);
      canvas.drawPath(path1, paint);

      // Second line of X (top-right to bottom-left)
      final t = (progress - 0.5) * 2;
      final path2 = Path();
      path2.moveTo(center.dx + radius, center.dy - radius);
      path2.lineTo(
        center.dx + radius - (radius * 2 * t),
        center.dy - radius + (radius * 2 * t),
      );
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(XMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Helper function to show the error animation dialog
void showErrorAnimation(
  BuildContext context, {
  required String message,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierDismissible: false,
    builder: (context) => ErrorAnimation(message: message),
  );
}
