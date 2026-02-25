import 'package:flutter/material.dart';

/// Gradient button with loading state and optional icon.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final Gradient gradient;
  final Color loadingBackgroundColor;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.loadingBackgroundColor = const Color(0xFF475569),
    this.textStyle,
  });

  // Desktop-style constructor with text-only label (no icon, no loading)
  const GradientButton.text({
    super.key,
    required String text,
    this.onPressed,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.textStyle,
  })  : label = text,
        isLoading = false,
        icon = null,
        fullWidth = false,
        loadingBackgroundColor = const Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        );

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: fullWidth ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          gradient: isLoading ? null : gradient,
          color: isLoading ? loadingBackgroundColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (icon != null && !isLoading) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              isLoading ? 'Ucitavanje...' : label,
              style: style.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
