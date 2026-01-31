import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

InputDecoration buildStrongholdInputDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.3),
    ),
    filled: true,
    fillColor: AppColors.backgroundLight,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: Colors.white.withValues(alpha: 0.5),
    ),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1,
      ),
    ),
  );
}
