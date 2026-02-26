import 'package:flutter/material.dart';

abstract final class AppColors {
  // ═══════════════════════════════════════════
  //  AETHER CORE PALETTE
  // ═══════════════════════════════════════════

  // Primary — Deep blue spectrum
  static const deepBlue = Color(0xFF0B1426);
  static const midBlue = Color(0xFF1E3A5F);
  static const navyBlue = Color(0xFF2B5EA7);

  // Accent — Electric blue x Cyan dual accent
  static const electric = Color(0xFF4F8EF7);
  static const cyan = Color(0xFF38BDF8);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7F9FC);
  static const background = Color(0xFFF0F4FA);

  // Text hierarchy
  static const textPrimary = Color(0xFF0B1426);
  static const textSecondary = Color(0xFF6B7C93);
  static const textMuted = Color(0xFF9AAFC4);

  // Borders
  static const border = Color(0x1F4F8EF7);
  static const borderLight = Color(0x0F4F8EF7);

  // Semantic
  static const success = Color(0xFF22D3A7);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFFB7185);
  static const purple = Color(0xFF8B5CF6);
  static const orange = Color(0xFFF97316);

  // ═══════════════════════════════════════════
  //  PREDEFINED GRADIENTS
  // ═══════════════════════════════════════════

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, midBlue, navyBlue],
    stops: [0.0, 0.6, 1.0],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electric, cyan],
  );

  // ═══════════════════════════════════════════
  //  SHADOWS
  // ═══════════════════════════════════════════

  static final cardShadow = [
    BoxShadow(
        color: electric.withOpacity(0.12),
        blurRadius: 40,
        offset: const Offset(0, 8)),
  ];

  static final cardShadowStrong = [
    BoxShadow(
        color: electric.withOpacity(0.18),
        blurRadius: 48,
        offset: const Offset(0, 12)),
  ];

  static final buttonShadow = [
    BoxShadow(
        color: electric.withOpacity(0.25),
        blurRadius: 16,
        offset: const Offset(0, 4)),
  ];

  static final cyanGlow = [
    BoxShadow(color: cyan.withOpacity(0.4), blurRadius: 12),
  ];

  // ═══════════════════════════════════════════
  //  BADGE SYSTEM
  // ═══════════════════════════════════════════

  static (Color, Color) badgeColors(String type) {
    return switch (type.toLowerCase()) {
      'active' || 'online' || 'success' || 'paid' => (
        success.withOpacity(0.12),
        success
      ),
      'pending' || 'warning' || 'processing' => (
        warning.withOpacity(0.12),
        warning
      ),
      'inactive' || 'danger' || 'expired' || 'cancelled' => (
        danger.withOpacity(0.12),
        danger
      ),
      'admin' || 'primary' => (electric.withOpacity(0.12), electric),
      'editor' || 'secondary' => (purple.withOpacity(0.12), purple),
      'viewer' || 'info' => (cyan.withOpacity(0.12), cyan),
      _ => (textMuted.withOpacity(0.12), textMuted),
    };
  }

  // ═══════════════════════════════════════════
  //  BACKWARD COMPATIBILITY
  // ═══════════════════════════════════════════

  static const primary = electric;
  static const primaryDim = Color(0x1A4F8EF7);
  static const primaryBorder = Color(0x334F8EF7);
  static const secondary = Color(0xFF6366F1);
  static const secondaryDim = Color(0x1A6366F1);
  static const error = danger;
  static const errorDim = Color(0x1AFB7185);
  static const accent = purple;
  static const accentDim = Color(0x1A8B5CF6);
  static const successDim = Color(0x1A22D3A7);
  static const warningDim = Color(0x1AFBBF24);
  static const orangeDim = Color(0x1AF97316);
  static const surfaceSolid = surface;
  static const surfaceHover = Color(0x084F8EF7);
  static const surfaceLight = surfaceAlt;
  static const surfaceElevated = surfaceAlt;
  static const textDark = textSecondary;
  static const shimmer = Color(0x084F8EF7);
  static const shimmerHighlight = Color(0x144F8EF7);
  static const overlay = Color(0x99000000);
  static const divider = borderLight;
  static const info = electric;
  static const gold = Color(0xFFFFD700);
  static const backgroundGradient = heroGradient;
  static const muted = textMuted;
  static const card = surface;
  static const panel = surface;
  static const accentLight = Color(0xFFFC8E9E);
  static const borderHover = Color(0x334F8EF7);
  static const bg1 = background;
  static const bg2 = background;
  static const editBlue = secondary;
  static const successDark = Color(0xFF1AAE8A);
  static const backgroundLight = surfaceAlt;
  static const backgroundDark = surface;
  static const cardBackground = surfaceAlt;
}
