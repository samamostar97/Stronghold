import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.textDark,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
