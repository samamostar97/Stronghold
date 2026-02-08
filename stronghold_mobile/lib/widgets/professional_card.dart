import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'glass_card.dart';
import 'gradient_button.dart';

class ProfessionalCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String phone;
  final String email;
  final VoidCallback onBook;

  const ProfessionalCard({
    super.key,
    required this.icon,
    required this.name,
    required this.phone,
    required this.email,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.headingSm,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _infoRow(LucideIcons.phone, phone),
          const SizedBox(height: AppSpacing.sm),
          _infoRow(LucideIcons.mail, email),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Napravi termin',
            icon: LucideIcons.calendar,
            onPressed: onBook,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData rowIcon, String text) {
    return Row(children: [
      Icon(rowIcon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodyMd,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
