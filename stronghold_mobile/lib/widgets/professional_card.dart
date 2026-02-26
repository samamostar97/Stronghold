import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class ProfessionalCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String phone;
  final String email;
  final VoidCallback onTap;

  const ProfessionalCard({
    super.key,
    required this.icon,
    required this.name,
    required this.phone,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _infoRow(LucideIcons.phone, phone),
          const SizedBox(height: AppSpacing.sm),
          _infoRow(LucideIcons.mail, email),
        ],
      ),
    );
  }

  Widget _infoRow(IconData rowIcon, String text) {
    return Row(children: [
      Icon(rowIcon, size: 16, color: Colors.white),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
