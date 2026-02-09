import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../widgets/glass_card.dart';
import 'change_password_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.arrowLeft,
                          color: AppColors.textPrimary),
                    ),
                  Expanded(
                    child:
                        Text('Postavke profila', style: AppTextStyles.headingMd),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SIGURNOST',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen()),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDim,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(LucideIcons.lock,
                                color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Promijeni lozinku',
                                    style: AppTextStyles.bodyBold),
                                const SizedBox(height: AppSpacing.xs),
                                Text('Azuriraj svoju lozinku',
                                    style: AppTextStyles.bodySm
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight,
                              color: AppColors.textDark, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
