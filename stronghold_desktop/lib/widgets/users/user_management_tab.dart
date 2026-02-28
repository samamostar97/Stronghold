import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../utils/error_handler.dart';
import '../shared/confirm_dialog.dart';
import '../shared/error_animation.dart';
import '../shared/success_animation.dart';
import 'user_edit_dialog.dart';

class UserManagementTab extends ConsumerWidget {
  const UserManagementTab({super.key, required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManagementCard(
            icon: LucideIcons.userCog,
            title: 'Izmijeni korisnicke podatke',
            description:
                'Promjena licnih podataka, email adrese, lozinke i profilne slike.',
            buttonText: 'Izmijeni podatke',
            buttonColor: AppColors.electric,
            onTap: () => _editUser(context, ref),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ManagementCard(
            icon: LucideIcons.trash2,
            title: 'Obrisi korisnika',
            description:
                'Trajno brisanje korisnickog naloga i svih povezanih podataka. Ova akcija je nepovratna.',
            buttonText: 'Obrisi korisnika',
            buttonColor: AppColors.danger,
            onTap: () => _deleteUser(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _editUser(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => UserEditDialog(user: user),
    );
    if (result == true && context.mounted) {
      showSuccessAnimation(context);
      ref.invalidate(userListProvider);
    } else if (result is String && context.mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteUser(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati korisnika "${user.username}"?\n\nOva akcija je nepovratna.',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(userListProvider.notifier).delete(user.id);
      if (context.mounted) {
        showSuccessAnimation(context);
        context.go('/users');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-user'));
      }
    }
  }
}

class _ManagementCard extends StatefulWidget {
  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  @override
  State<_ManagementCard> createState() => _ManagementCardState();
}

class _ManagementCardState extends State<_ManagementCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.buttonColor.withValues(alpha: 0.08),
              borderRadius: AppSpacing.buttonRadius,
            ),
            child: Icon(widget.icon, color: widget.buttonColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(widget.description, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: widget.buttonColor
                      .withValues(alpha: _hover ? 0.15 : 0.08),
                  borderRadius: AppSpacing.buttonRadius,
                  border: Border.all(
                    color: widget.buttonColor
                        .withValues(alpha: _hover ? 0.4 : 0.2),
                  ),
                ),
                child: Text(
                  widget.buttonText,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: widget.buttonColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
