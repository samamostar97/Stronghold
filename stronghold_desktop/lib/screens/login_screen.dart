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
        const ParticleBackground(
          particleColor: Color(0xFF38BDF8),
          particleCount: 80,
          connectDistance: 140,
        ),
        // Login form centered
        const Center(child: LoginForm()),
      ]),
    );
  }
}
