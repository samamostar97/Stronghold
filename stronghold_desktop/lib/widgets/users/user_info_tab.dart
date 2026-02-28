import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/membership_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/error_handler.dart';
import '../memberships/membership_payment_dialog.dart';
import '../shared/confirm_dialog.dart';
import '../shared/error_animation.dart';
import '../shared/success_animation.dart';

class UserInfoTab extends ConsumerWidget {
  const UserInfoTab({super.key, required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressAsync = ref.watch(userAddressProvider(user.id));
    final membershipAsync =
        ref.watch(userHasActiveMembershipProvider(user.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: AppSpacing.xxl),
          _MembershipCard(
            user: user,
            membershipAsync: membershipAsync,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PersonalInfoCard(user: user)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _AddressCard(addressAsync: addressAsync),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppSpacing.cardRadius,
      ),
      child: Row(
        children: [
          user.profileImageUrl != null
              ? ClipRRect(
                  borderRadius: AppSpacing.avatarRadius,
                  child: Image.network(
                    ApiConfig.imageUrl(user.profileImageUrl!),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        AvatarWidget(initials: initials, size: 72),
                  ),
                )
              : AvatarWidget(initials: initials, size: 72),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTextStyles.heroTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: AppTextStyles.bodySecondary
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.email,
                style:
                    AppTextStyles.caption.copyWith(color: Colors.white60),
              ),
              if (user.phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber,
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white60),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBERSHIP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard({
    required this.user,
    required this.membershipAsync,
  });

  final UserResponse user;
  final AsyncValue<bool> membershipAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.creditCard, color: AppColors.electric, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status clanarine', style: AppTextStyles.label),
                const SizedBox(height: 4),
                membershipAsync.when(
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.electric,
                    ),
                  ),
                  error: (_, _) => Text(
                    'Greska pri provjeri',
                    style: AppTextStyles.bodySecondary
                        .copyWith(color: AppColors.danger),
                  ),
                  data: (isActive) => _StatusBadge(isActive: isActive),
                ),
              ],
            ),
          ),
          membershipAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (isActive) => isActive
                ? _ActionButton(
                    text: 'Ukini clanarinu',
                    color: AppColors.danger,
                    icon: LucideIcons.xCircle,
                    onTap: () => _revokeMembership(context, ref),
                  )
                : _ActionButton(
                    text: 'Dodaj clanarinu',
                    color: AppColors.success,
                    icon: LucideIcons.plusCircle,
                    onTap: () => _assignMembership(context, ref),
                  ),
          ),
        ],
      ),
    );
  }

  void _invalidateAll(WidgetRef ref) {
    ref.invalidate(userHasActiveMembershipProvider(user.id));
    ref.invalidate(userPaymentsProvider(UserPaymentsParams(
      userId: user.id,
      filter: MembershipQueryFilter(pageSize: 10),
    )));
  }

  Future<void> _assignMembership(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => MembershipPaymentDialog(user: user),
    );
    if (result == true && context.mounted) {
      showSuccessAnimation(context);
      _invalidateAll(ref);
    }
  }

  Future<void> _revokeMembership(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Ukidanje clanarine',
        message:
            'Jeste li sigurni da zelite ukinuti clanarinu za "${user.fullName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(membershipOperationsProvider.notifier)
          .revokeMembership(user.id);
      if (context.mounted) {
        showSuccessAnimation(context);
      }
      _invalidateAll(ref);
    } catch (e) {
      if (context.mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'revoke-membership'));
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = isActive
        ? (AppColors.successDim, AppColors.success)
        : (AppColors.textMuted.withValues(alpha: 0.15), AppColors.textMuted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: Text(
        isActive ? 'AKTIVNA' : 'NEAKTIVNA',
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
            color: widget.color.withValues(alpha: _hover ? 0.15 : 0.08),
            borderRadius: AppSpacing.buttonRadius,
            border: Border.all(
              color: widget.color.withValues(alpha: _hover ? 0.4 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.text,
                style: AppTextStyles.bodyMedium.copyWith(color: widget.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERSONAL INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.user});
  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LICNI PODACI', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(
            icon: LucideIcons.user,
            label: 'Korisnicko ime',
            value: user.username,
          ),
          _InfoRow(
            icon: LucideIcons.mail,
            label: 'Email',
            value: user.email,
          ),
          _InfoRow(
            icon: LucideIcons.phone,
            label: 'Telefon',
            value: user.phoneNumber.isNotEmpty ? user.phoneNumber : '-',
          ),
          _InfoRow(
            icon: LucideIcons.users,
            label: 'Spol',
            value: user.genderDisplay,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADDRESS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.addressAsync});
  final AsyncValue<AddressResponse?> addressAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADRESA ZA DOSTAVU', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.lg),
          addressAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.electric,
                  ),
                ),
              ),
            ),
            error: (_, _) => Text(
              'Greska pri ucitavanju adrese',
              style: AppTextStyles.bodySecondary
                  .copyWith(color: AppColors.danger),
            ),
            data: (address) {
              if (address == null) {
                return Row(
                  children: [
                    Icon(LucideIcons.mapPinOff,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.md),
                    Text('Nema sacuvane adrese',
                        style: AppTextStyles.caption),
                  ],
                );
              }
              return Column(
                children: [
                  _InfoRow(
                    icon: LucideIcons.mapPin,
                    label: 'Ulica',
                    value: address.street,
                  ),
                  _InfoRow(
                    icon: LucideIcons.building2,
                    label: 'Grad',
                    value: address.city,
                  ),
                  _InfoRow(
                    icon: LucideIcons.hash,
                    label: 'Postanski broj',
                    value: address.postalCode,
                  ),
                  _InfoRow(
                    icon: LucideIcons.globe,
                    label: 'Drzava',
                    value: address.country,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED INFO ROW
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
