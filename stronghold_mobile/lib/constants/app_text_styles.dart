import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // ═══════════════════════════════════════════
  //  AETHER TYPOGRAPHY — Space Grotesk
  // ═══════════════════════════════════════════

  // Display
  static TextStyle get heroTitle => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.9,
        height: 1.2,
      );

  static TextStyle get pageTitle => GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.78,
        height: 1.25,
      );

  // Headings
  static TextStyle get cardTitle => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get sectionTitle => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Metrics
  static TextStyle get metricLarge => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.56,
        height: 1.1,
      );

  static TextStyle get metricMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.44,
        height: 1.2,
      );

  // Body
  static TextStyle get body => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodySecondary => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Small
  static TextStyle get caption => GoogleFonts.spaceGrotesk(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get badge => GoogleFonts.spaceGrotesk(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get overline => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.88,
        height: 1.3,
      );

  static TextStyle get tableHeader => GoogleFonts.spaceGrotesk(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.84,
        height: 1.2,
      );

  // ═══════════════════════════════════════════
  //  BACKWARD COMPATIBILITY
  // ═══════════════════════════════════════════

  static TextStyle get statLg => metricLarge;
  static TextStyle get stat => metricMedium;
  static TextStyle get statSm => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
  static TextStyle get headingLg => pageTitle;
  static TextStyle get headingMd => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );
  static TextStyle get headingSm => cardTitle;
  static TextStyle get bodyLg => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
  static TextStyle get bodyMd => bodySecondary;
  static TextStyle get bodyBold => bodyMedium;
  static TextStyle get bodySm => caption;
  static TextStyle get buttonLg => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
  static TextStyle get buttonMd => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  static TextStyle get tabActive => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.electric,
      );
  static TextStyle get tabInactive => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}
