import 'package:flutter/material.dart';

/// Shared color palette for admin screens
abstract class AppColors {
  // Core palette
  static const bg1 = Color(0xFF1A1D2E);
  static const bg2 = Color(0xFF16192B);
  static const card = Color(0xFF22253A);
  static const panel = Color(0xFF2A2D3E);
  static const border = Color(0xFF3A3D4E);
  static const muted = Color(0xFF8A8D9E);
  static const accent = Color(0xFFFF5757);
  static const accentLight = Color(0xFFFF6B6B);
  static const editBlue = Color(0xFF4A9EFF);

  // Semantic colors
  static const success = Color(0xFF2ECC71);
  static const successDark = Color(0xFF27AE60);
  static const warning = Color(0xFFFFB300);
  static const info = Color(0xFF4A9EFF);
  static const surfaceHover = Color(0xFF2A2D42);

  // Text hierarchy
  static const textPrimary = Color(0xDEFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);
}
