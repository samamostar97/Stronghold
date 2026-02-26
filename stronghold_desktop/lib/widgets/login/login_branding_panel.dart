import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Left branding panel — hero gradient with particles and decorative elements.
class LoginBrandingPanel extends StatelessWidget {
  const LoginBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Hero gradient background
      Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      ),
      // Decorative concentric circles (top-right)
      Positioned(
        top: -60,
        right: -40,
        child: _decorativeCircles(),
      ),
      // Cyan radial orb (bottom)
      Positioned(
        bottom: -80,
        left: 60,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.cyan.withOpacity(0.08),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      const ParticleBackground(
        particleColor: Color(0xFF38BDF8),
        particleCount: 50,
      ),
      // Content
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: _logo(),
        ),
      ),
      // Bottom accent line
      Positioned(
        left: 48,
        right: 48,
        bottom: 40,
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              AppColors.electric,
              AppColors.cyan,
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _decorativeCircles() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(children: [
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.04),
                width: 1,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _logo() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppSpacing.panelRadius,
          boxShadow: AppColors.cyanGlow,
        ),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.shield, color: Colors.white, size: 32),
      )
          .animate()
          .fadeIn(duration: Motion.dramatic, curve: Motion.curve)
          .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: Motion.dramatic,
              curve: Motion.curve),
      const SizedBox(height: AppSpacing.lg),
      Text('TheStronghold', style: AppTextStyles.heroTitle)
          .animate(delay: 200.ms)
          .fadeIn(duration: Motion.smooth, curve: Motion.curve)
          .slideY(begin: 0.2, end: 0, duration: Motion.smooth),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'ADMINISTRATORSKI CENTAR',
        style: AppTextStyles.overline.copyWith(
          color: AppColors.cyan,
          letterSpacing: 3,
        ),
      )
          .animate(delay: 400.ms)
          .fadeIn(duration: Motion.smooth, curve: Motion.curve),
    ]);
  }
}
