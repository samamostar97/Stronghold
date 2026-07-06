import 'package:flutter/material.dart';

/// Dizajn sistem aplikacije - flat/tinted pristup, navy monohromatika,
/// kartice sa tankim borderom umjesto sjena.
class AppTheme {
  // paleta
  static const Color navy = Color(0xFF1E3A5F);
  static const Color navyDark = Color(0xFF14293F);
  static const Color navyTint = Color(0xFFE8EEF5);
  static const Color background = Color(0xFFF6F7F9);
  static const Color cardBorder = Color(0xFFE3E6EA);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF5C6470);

  // semanticke boje statusa (koristi ih StatusChip)
  static const Color success = Color(0xFF2F9E44);
  static const Color warning = Color(0xFFE8890C);
  static const Color danger = Color(0xFFC92A2A);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      surface: Colors.white,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: textPrimary),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dataTableTheme: DataTableThemeData(
        columnSpacing: 24,
        horizontalMargin: 16,
        headingRowColor: const WidgetStatePropertyAll(Color(0xFFF0F3F7)),
        headingTextStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: textSecondary,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13.5,
          color: textPrimary,
        ),
        dividerThickness: 0.6,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        decoration: const BoxDecoration(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: navy, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger, width: 1.6),
        ),
        isDense: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: cardBorder),
          foregroundColor: navy,
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navy,
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 19,
          color: textPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        labelStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 12.5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: navyDark,
        contentTextStyle:
            const TextStyle(fontFamily: 'Manrope', color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(color: cardBorder, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: navy,
        unselectedLabelColor: textSecondary,
        indicatorColor: navy,
        labelStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Manrope'),
      ),
    );
  }
}
