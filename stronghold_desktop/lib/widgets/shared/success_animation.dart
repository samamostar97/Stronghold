import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';

/// Tracks the current toast so we can dismiss it before showing a new one.
OverlayEntry? _activeSuccessEntry;

/// Non-blocking success toast that slides in from the top-right.
/// Uses an OverlayEntry so it doesn't block user interaction.
/// Dismisses any previous toast before showing the new one.
void showSuccessAnimation(BuildContext context, {String? message}) {
  // Remove previous toast if still showing
  _activeSuccessEntry?.remove();
  _activeSuccessEntry = null;

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _SuccessToast(
      message: message ?? 'Uspjesno!',
      onDismiss: () {
        entry.remove();
        if (_activeSuccessEntry == entry) _activeSuccessEntry = null;
      },
    ),
  );

  _activeSuccessEntry = entry;
  overlay.insert(entry);
}

class _SuccessToast extends StatefulWidget {
  const _SuccessToast({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // Slide in from right (0-300ms)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.12, curve: Curves.easeOutCubic),
    ));

    // Fade in (0-200ms)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.08, curve: Curves.easeOut),
    );

    // Ring progress (100-700ms)
    _ringAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.04, 0.29, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) {
      // Auto-dismiss after the animation completes (at 2400ms)
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                  ...AppShadows.elevatedShadow,
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated ring with checkmark
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _ringAnimation,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RingCheckPainter(
                            progress: _ringAnimation.value,
                            ringColor: AppColors.success,
                            checkColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

/// Draws an animated ring that fills from 0 to 360 degrees,
/// then draws a checkmark inside once the ring completes.
class _RingCheckPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color checkColor;

  _RingCheckPainter({
    required this.progress,
    required this.ringColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background ring (subtle)
    final bgPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Animated ring
    final ringProgress = (progress * 1.5).clamp(0.0, 1.0);
    if (ringProgress > 0) {
      final ringPaint = Paint()
        ..color = ringColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * ringProgress,
        false,
        ringPaint,
      );
    }

    // Checkmark (after ring is ~60% done)
    final checkProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = checkColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final scale = 0.35;
      final startX = center.dx - 8 * scale;
      final startY = center.dy + 2 * scale;
      final midX = center.dx - 2 * scale;
      final midY = center.dy + 8 * scale;
      final endX = center.dx + 10 * scale;
      final endY = center.dy - 6 * scale;

      final path = Path();
      path.moveTo(startX, startY);

      if (checkProgress < 0.5) {
        final t = checkProgress * 2;
        path.lineTo(
          startX + (midX - startX) * t,
          startY + (midY - startY) * t,
        );
      } else {
        path.lineTo(midX, midY);
        final t = (checkProgress - 0.5) * 2;
        path.lineTo(
          midX + (endX - midX) * t,
          midY + (endY - midY) * t,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_RingCheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
