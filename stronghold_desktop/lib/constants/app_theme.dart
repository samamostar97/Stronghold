import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Centralized ThemeData for Aether design system.
abstract class AppTheme {
  static ThemeData aetherTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.electric,
        secondary: AppColors.cyan,
        error: AppColors.danger,
        surface: AppColors.surface,
      ),
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
        ),
        elevation: 0,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.textMuted.withOpacity(0.4),
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.electric),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  /// Backward compat alias
  static ThemeData darkTheme() => aetherTheme();
}

// ═══════════════════════════════════════════
//  BACKWARD COMPATIBILITY CLASSES
// ═══════════════════════════════════════════

abstract class AppShadows {
  static final elevatedShadow = [
    BoxShadow(
      color: AppColors.electric.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.electric.withOpacity(0.08),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  static final cardShadow = AppColors.cardShadow;
}

abstract class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double pill = 100;
}

abstract class AppGradients {
  static const accent = AppColors.accentGradient;
  static const background = AppColors.heroGradient;
  static const cardBorder = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE2EAFC), Color(0xFFFFFFFF)],
  );
}
