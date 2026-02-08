import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

Future<void> showSuccessFeedback(BuildContext context, String message) async {
  await _showFeedback(context, message, isSuccess: true);
}

Future<void> showErrorFeedback(BuildContext context, String message) async {
  await _showFeedback(context, message, isSuccess: false);
}

Future<void> _showFeedback(
  BuildContext context,
  String message, {
  required bool isSuccess,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.overlay,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FeedbackDialog(isSuccess: isSuccess, message: message);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class FeedbackDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;

  const FeedbackDialog({
    super.key,
    required this.isSuccess,
    required this.message,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? AppColors.success : AppColors.error;
    final icon =
        widget.isSuccess ? LucideIcons.check : LucideIcons.x;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AnimatedBuilder(
              animation: _opacityAnim,
              builder: (context, child) => Opacity(
                opacity: _opacityAnim.value,
                child: Text(
                  widget.message,
                  style: AppTextStyles.bodyBold,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
