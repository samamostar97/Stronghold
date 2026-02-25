import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'particle_background.dart';

/// Left branding panel for the login screen with particle background,
/// ambient glows, logo, and headline.
class LoginBrandingPanel extends StatelessWidget {
  const LoginBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: AppColors.background),
      // Ambient glows
      Positioned(
        top: -100,
        left: -100,
        child: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.primary.withValues(alpha: 0.06),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      Positioned(
        bottom: -80,
        right: -60,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.secondary.withValues(alpha: 0.05),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      const ParticleBackground(),
      // Content
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl + 16),
          child: _logo(),
        ),
      ),
      // Bottom gradient line
      Positioned(
        left: AppSpacing.xxxl,
        right: AppSpacing.xxxl,
        bottom: AppSpacing.xxxl,
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              AppColors.primary,
              AppColors.secondary,
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _logo() => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.shield, color: Colors.white, size: 32),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('TheStronghold',
            style: AppTextStyles.headingMd.copyWith(fontSize: 26)),
        const SizedBox(height: AppSpacing.xs),
        Text('ADMINISTRATORSKI CENTAR',
            style: AppTextStyles.label.copyWith(
                color: AppColors.primary, letterSpacing: 3, fontSize: 11)),
      ]);

}
