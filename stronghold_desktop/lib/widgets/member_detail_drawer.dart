import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'avatar_widget.dart';
import 'gradient_button.dart';

/// Tier 2 — Slide-in detail panel from the right.
class MemberDetailDrawer extends StatelessWidget {
  const MemberDetailDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    this.plan,
    this.status,
    this.visits = 0,
    this.joinDate,
    required this.onClose,
    this.onEdit,
  });

  final String name;
  final String email;
  final String phone;
  final String initials;
  final String? plan;
  final String? status;
  final int visits;
  final String? joinDate;
  final VoidCallback onClose;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black54),
          ),
          // Drawer
          Align(
            alignment: Alignment.centerRight,
            child: _DrawerBody(
              name: name,
              email: email,
              phone: phone,
              initials: initials,
              plan: plan,
              status: status,
              visits: visits,
              joinDate: joinDate,
              onClose: onClose,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerBody extends StatelessWidget {
  const _DrawerBody({
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    this.plan,
    this.status,
    required this.visits,
    this.joinDate,
    required this.onClose,
    this.onEdit,
  });

  final String name, email, phone, initials;
  final String? plan, status, joinDate;
  final int visits;
  final VoidCallback onClose;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      color: AppColors.surfaceSolid,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
                onPressed: onClose,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(child: AvatarWidget(initials: initials, size: 64)),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(name, style: AppTextStyles.headingMd, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(email, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _InfoRow(icon: LucideIcons.phone, label: phone),
            if (plan != null) _InfoRow(icon: LucideIcons.creditCard, label: plan!),
            if (status != null) _InfoRow(icon: LucideIcons.activity, label: status!),
            _InfoRow(icon: LucideIcons.barChart2, label: '$visits posjeta'),
            if (joinDate != null) _InfoRow(icon: LucideIcons.calendar, label: joinDate!),
            const Spacer(),
            if (onEdit != null)
              SizedBox(
                width: double.infinity,
                child: GradientButton(text: 'Uredi', onTap: onEdit!),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMd,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
