import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text style tokens using DM Sans via google_fonts.
abstract class AppTextStyles {
  static TextStyle get statLg => GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get stat => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 22,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMd => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 20,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSm => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMd => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyBold => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySm => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 12,
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
        letterSpacing: 0.03 * 11,
      );

  static TextStyle get navItem => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get navItemActive => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );
}
