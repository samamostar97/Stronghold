import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get heroTitle => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static TextStyle get pageTitle => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get metricLarge => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.45,
    height: 1.15,
  );

  static TextStyle get metricMedium => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get bodySecondary => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.35,
  );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle get badge => GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get overline => GoogleFonts.plusJakartaSans(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.9,
    height: 1.25,
  );

  static TextStyle get tableHeader => GoogleFonts.plusJakartaSans(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.85,
    height: 1.2,
  );

  // Backward compatibility aliases
  static TextStyle get statLg => metricLarge;
  static TextStyle get stat => metricMedium;

  static TextStyle get headingMd => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headingSm => cardTitle;
  static TextStyle get bodyMd => bodySecondary;
  static TextStyle get bodyBold => bodyMedium;
  static TextStyle get bodySm => caption;
  static TextStyle get navItem => bodySecondary;
  static TextStyle get navItemActive =>
      bodyMedium.copyWith(color: AppColors.primary);
}
