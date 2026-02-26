import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';

/// Error toast that slides in from the top-right with a shake effect.
/// Uses showDialog so it's dismissible via close button.
void showErrorAnimation(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (_) => _ErrorToast(message: message),
  );
}

class _ErrorToast extends StatefulWidget {
  const _ErrorToast({required this.message});

  final String message;

  @override
  State<_ErrorToast> createState() => _ErrorToastState();
}

class _ErrorToastState extends State<_ErrorToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Slide in from right (0-300ms)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.15, curve: Curves.easeOutCubic),
    ));

    // Fade in (0-200ms)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.1, curve: Curves.easeOut),
    );

    // Shake effect (300-700ms) - 3 oscillations
    _shakeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.35, curve: Curves.easeOut),
    );

    // Subtle pulse on the icon (loops via sin)
    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.linear),
    );

    _controller.forward().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _shakeOffset(double value) {
    if (value <= 0) return 0;
    // Damped sine wave: 3 oscillations, decaying amplitude
    return math.sin(value * math.pi * 6) * 6 * (1 - value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shake = _shakeOffset(_shakeAnimation.value);
        final pulse = 1.0 + math.sin(_pulseAnimation.value * math.pi * 2) * 0.03;

        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 24, right: 24),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(shake, 0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                      decoration: BoxDecoration(
                        color: AppColors.midBlue,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 4),
                          ),
                          ...AppShadows.elevatedShadow,
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Error icon with pulse
                          Transform.scale(
                            scale: pulse,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Title + message
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Greska',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 18),
                            color: AppColors.muted,
                            splashRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
