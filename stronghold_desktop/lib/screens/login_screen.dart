import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Full-screen gradient background
        Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        // Particle network across the entire screen
        ParticleBackground(
          particleColor: AppColors.primary.withValues(alpha: 0.45),
          particleCount: 60,
          connectDistance: 120,
        ),
        // Login form centered
        const Center(child: LoginForm()),
      ]),
    );
  }
}
