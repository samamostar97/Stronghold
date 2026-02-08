import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // -- Headings --
  static TextStyle get headingLg => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.48,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMd => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSm => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // -- Stats --
  static TextStyle get stat => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.56,
        color: AppColors.textPrimary,
      );

  static TextStyle get statSm => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // -- Body --
  static TextStyle get bodyLg => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMd => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyBold => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySm => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  // -- Labels & captions --
  // Note: label style expects uppercase text — apply .toUpperCase() on the string
  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.textMuted,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      );

  static TextStyle get badge => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.33,
      );

  // -- Buttons --
  static TextStyle get buttonLg => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonMd => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // -- Tabs --
  static TextStyle get tabActive => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get tabInactive => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}
