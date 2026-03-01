import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  static ThemeData aetherTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
        elevation: 0,
      ),
      dividerColor: AppColors.borderLight,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
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
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.smallRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.textMuted.withValues(alpha: 0.45),
        ),
        radius: const Radius.circular(999),
        thickness: WidgetStateProperty.all(7),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
        ),
      ),
    );
  }

  static ThemeData darkTheme() => aetherTheme();
}

abstract class AppShadows {
  static final elevatedShadow = <BoxShadow>[
    const BoxShadow(
      color: Color(0x190F172A),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  static final cardShadow = AppColors.cardShadow;
}

abstract class AppRadius {
  static const double small = 8;
  static const double medium = 10;
  static const double large = 12;
  static const double xl = 14;
  static const double pill = 100;
}

abstract class AppGradients {
  static const accent = AppColors.accentGradient;
  static const background = AppColors.backgroundGradient;
  static const cardBorder = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3F5FA), Color(0xFFFFFFFF)],
  );
}
