import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFe63946);
  static const Color success = Color(0xFF4CAF50);
  static const Color gold = Color(0xFFFFD700);
  static const Color backgroundLight = Color(0xFF1a1a2e);
  static const Color backgroundDark = Color(0xFF16213e);
  static const Color cardBackground = Color(0xFF0f0f1a);
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundDark],
  );
}
