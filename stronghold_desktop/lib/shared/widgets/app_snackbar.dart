import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_rounded);
  }

  static void successWithMessenger(
      ScaffoldMessengerState messenger, String message) {
    _showWithMessenger(
        messenger, message, AppColors.success, Icons.check_circle_rounded);
  }

  static void errorWithMessenger(
      ScaffoldMessengerState messenger, String message) {
    _showWithMessenger(
        messenger, message, AppColors.error, Icons.error_rounded);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(message, color, icon));
  }

  static void _showWithMessenger(
      ScaffoldMessengerState messenger, String message, Color color, IconData icon) {
    messenger.showSnackBar(_buildSnackBar(message, color, icon));
  }

  static SnackBar _buildSnackBar(String message, Color color, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      duration: const Duration(seconds: 3),
      elevation: 8,
    );
  }
}
