import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'gradient_button.dart';

class ContentStateDisplay extends StatelessWidget {
  const ContentStateDisplay({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.child,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greška pri učitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokušaj ponovo', onTap: onRetry),
          ],
        ),
      );
    }

    return child;
  }
}
