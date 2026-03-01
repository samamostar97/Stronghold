import 'package:flutter/material.dart';

abstract final class AppColors {
  // Core console palette (Appwrite-like)
  static const background = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2F4F8);
  static const surfaceElevated = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF94A3B8);

  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFEEF2F7);
  static const borderHover = Color(0xFFD8DEE8);

  static const primary = Color(0xFF3860F6);
  static const secondary = Color(0xFF0EA5E9);
  static const accent = Color(0xFF06B6D4);

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);

  static const deepBlue = Color(0xFF111827);
  static const midBlue = Color(0xFF1F2937);
  static const navyBlue = Color(0xFF374151);
  static const electric = primary;
  static const cyan = secondary;
  static const danger = error;
  static const orange = Color(0xFFF97316);
  static const purple = Color(0xFF7C3AED);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FAFC), Color(0xFFF3F5FA)],
  );

  static const heroGradient = backgroundGradient;
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const surfaceSolid = surface;
  static const surfaceLight = surfaceAlt;
  static const surfaceHover = Color(0xFFF8FAFD);
  static const textDark = textSecondary;
  static const shimmer = Color(0xFFF1F4F9);
  static const shimmerHighlight = Color(0xFFF9FBFE);
  static const overlay = Color(0x8A111827);
  static const divider = borderLight;
  static const gold = Color(0xFFEAB308);
  static const muted = textMuted;
  static const card = surface;
  static const panel = surface;
  static const accentLight = Color(0xFF60A5FA);
  static const bg1 = background;
  static const bg2 = background;
  static const editBlue = info;
  static const successDark = Color(0xFF15803D);

  static const primaryDim = Color(0x143860F6);
  static const primaryBorder = Color(0x403860F6);
  static const secondaryDim = Color(0x140EA5E9);
  static const errorDim = Color(0x14DC2626);
  static const accentDim = Color(0x1406B6D4);
  static const successDim = Color(0x1416A34A);
  static const warningDim = Color(0x14D97706);
  static const orangeDim = Color(0x14F97316);

  static final cardShadow = <BoxShadow>[
    const BoxShadow(
      color: Color(0x110F172A),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static final cardShadowStrong = <BoxShadow>[
    const BoxShadow(
      color: Color(0x190F172A),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];

  static final buttonShadow = <BoxShadow>[
    const BoxShadow(
      color: Color(0x253860F6),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static final cyanGlow = <BoxShadow>[
    const BoxShadow(
      color: Color(0x2B0EA5E9),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  static (Color, Color) badgeColors(String type) {
    return switch (type.toLowerCase()) {
      'active' || 'online' || 'success' || 'paid' => (successDim, success),
      'pending' || 'warning' || 'processing' => (warningDim, warning),
      'inactive' || 'danger' || 'expired' || 'cancelled' => (errorDim, error),
      'admin' || 'primary' => (primaryDim, primary),
      'editor' || 'secondary' => (accentDim, accent),
      'viewer' || 'info' => (secondaryDim, secondary),
      _ => (const Color(0x1494A3B8), textMuted),
    };
  }
}
