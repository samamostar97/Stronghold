import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'navigation_shell.dart';

class LoginSuccessScreen extends StatefulWidget {
  final String userName;
  final String? userImageUrl;
  final bool hasActiveMembership;

  const LoginSuccessScreen({
    super.key,
    required this.userName,
    this.userImageUrl,
    required this.hasActiveMembership,
  });

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NavigationShell(
              userName: widget.userName,
              userImageUrl: widget.userImageUrl,
              hasActiveMembership: widget.hasActiveMembership,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.successDim,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success, width: 3),
                    ),
                    child: const Icon(LucideIcons.check,
                        size: 60, color: AppColors.success),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      Text('Uspjesna prijava!', style: AppTextStyles.stat),
                      const SizedBox(height: AppSpacing.md),
                      Text('Dobrodosli nazad',
                          style: AppTextStyles.bodyLg
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Ucitavanje...',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
