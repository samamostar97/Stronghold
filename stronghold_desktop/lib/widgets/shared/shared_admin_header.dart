import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../screens/login_screen.dart';


/// Admin header with greeting, date, profile avatar, notification bell.
class SharedAdminHeader extends StatelessWidget {
  const SharedAdminHeader({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd.MM.yyyy  HH:mm').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_greeting, Admin',
                style: AppTextStyles.headingMd,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: AppTextStyles.bodySm,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),

        // Notification bell with dot
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                LucideIcons.bell,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),

        // Profile avatar + dropdown
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          color: AppColors.surfaceSolid,
          onSelected: (value) async {
            if (value == 'logout') {
              await TokenStorage.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(LucideIcons.user, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: AppSpacing.md),
                  Text('Profil', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(LucideIcons.logOut, color: AppColors.error, size: 18),
                  const SizedBox(width: AppSpacing.md),
                  Text('Odjavi se', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
          child: const AvatarWidget(initials: 'AD', size: 36),
        ),
      ],
    );
  }
}
