import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Multi-layer shadow presets for depth hierarchy
abstract class AppShadows {
  /// Standard card shadow — tight contact + medium lift
  static final cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  /// Elevated shadow for dialogs, overlays, command palette
  static final elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];
}

/// Shared border radius values
abstract class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double pill = 100;
}

/// Gradient presets
abstract class AppGradients {
  /// Accent gradient for buttons and highlights
  static const accent = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient used in scaffold
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bg1, AppColors.bg2],
  );

  /// Lit-from-above border gradient for cards
  static const cardBorder = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A4D5E), Color(0xFF2A2D3E)],
  );
}

/// Typography presets using Plus Jakarta Sans font
abstract class AppTypography {
  static const _fontFamily = 'PlusJakartaSans';

  static const h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: AppColors.muted,
  );

  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.muted,
  );

  static const statNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
