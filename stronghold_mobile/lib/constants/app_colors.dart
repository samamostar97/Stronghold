import 'package:flutter/material.dart';

abstract class AppColors {
  // -- Backgrounds --
  static const background = Color(0xFF0C1222);
  static const surface = Color(0xFF0F172A);
  static const surfaceLight = Color(0xFF131D32);
  static const surfaceElevated = Color(0xFF172033);

  // -- Borders --
  static const border = Color(0x0DFFFFFF);
  static const borderLight = Color(0x0AFFFFFF);

  // -- Primary (cyan) --
  static const primary = Color(0xFF22D3EE);
  static const primaryDim = Color(0x1A22D3EE);
  static const primaryBorder = Color(0x3322D3EE);

  // -- Secondary (indigo) --
  static const secondary = Color(0xFF6366F1);
  static const secondaryDim = Color(0x1A6366F1);

  // -- Semantic --
  static const success = Color(0xFF34D399);
  static const successDim = Color(0x1A34D399);

  static const warning = Color(0xFFF59E0B);
  static const warningDim = Color(0x1AF59E0B);

  static const error = Color(0xFFFB7185);
  static const errorDim = Color(0x1AFB7185);

  static const accent = Color(0xFFA78BFA);
  static const accentDim = Color(0x1AA78BFA);

  static const orange = Color(0xFFF97316);
  static const orangeDim = Color(0x1AF97316);

  // -- Text --
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const textDark = Color(0xFF475569);

  // -- Utility --
  static const shimmer = Color(0x08FFFFFF);
  static const shimmerHighlight = Color(0x14FFFFFF);
  static const overlay = Color(0x99000000);
  static const divider = Color(0x0AFFFFFF);

  // -- Legacy aliases (backward compatibility) --
  static const backgroundLight = surfaceLight;
  static const backgroundDark = surface;
  static const cardBackground = surfaceLight;
  static const gold = Color(0xFFFFD700);
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
}
