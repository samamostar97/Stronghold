import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../providers/api_providers.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

class UserDetailDrawer extends ConsumerStatefulWidget {
  const UserDetailDrawer({
    super.key,
    required this.user,
    required this.onClose,
    this.onEdit,
  });

  final UserResponse user;
  final VoidCallback onClose;
  final VoidCallback? onEdit;

  @override
  ConsumerState<UserDetailDrawer> createState() => _UserDetailDrawerState();
}

class _UserDetailDrawerState extends ConsumerState<UserDetailDrawer> {
  AddressResponse? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final client = ref.read(apiClientProvider);
      final service = AddressService(client);
      final address = await service.getByUserId(widget.user.id);
      if (mounted) {
        setState(() {
          _address = address;
          _loadingAddress = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: AppColors.deepBlue.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Drawer panel
          Align(
            alignment: Alignment.centerRight,
            child: _DrawerPanel(
              user: widget.user,
              address: _address,
              loadingAddress: _loadingAddress,
              onClose: widget.onClose,
              onEdit: widget.onEdit,
            )
                .animate()
                .fadeIn(duration: Motion.normal, curve: Motion.curve)
                .slideX(
                  begin: 0.1,
                  end: 0,
                  duration: Motion.normal,
                  curve: Motion.curve,
                ),
          ),
        ],
      ),
    );
  }
}

class _DrawerPanel extends StatelessWidget {
  const _DrawerPanel({
    required this.user,
    required this.address,
    required this.loadingAddress,
    required this.onClose,
    this.onEdit,
  });

  final UserResponse user;
  final AddressResponse? address;
  final bool loadingAddress;
  final VoidCallback onClose;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.cardShadowStrong,
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(LucideIcons.x,
                    color: AppColors.textMuted, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarHeader(user: user, initials: initials),
                    const SizedBox(height: AppSpacing.xxl),
                    _InfoSection(
                      label: 'LICNI PODACI',
                      rows: [
                        _InfoData(LucideIcons.user, 'Korisnicko ime', user.username),
                        _InfoData(LucideIcons.phone, 'Telefon', user.phoneNumber),
                        _InfoData(LucideIcons.users, 'Spol', user.genderDisplay),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _AddressSection(
                      address: address,
                      loading: loadingAddress,
                    ),
                  ],
                ),
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: GradientButton.text(text: 'Uredi', onPressed: onEdit!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({required this.user, required this.initials});
  final UserResponse user;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          user.profileImageUrl != null
              ? ClipRRect(
                  borderRadius: AppSpacing.avatarRadius,
                  child: Image.network(
                    ApiConfig.imageUrl(user.profileImageUrl!),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, st) =>
                        AvatarWidget(initials: initials, size: 72),
                  ),
                )
              : AvatarWidget(initials: initials, size: 72),
          const SizedBox(height: AppSpacing.lg),
          Text(
            user.fullName,
            style: AppTextStyles.headingMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.label, required this.rows});
  final String label;
  final List<_InfoData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final row in rows) _InfoRow(data: row),
      ],
    );
  }
}

class _InfoData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoData(this.icon, this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});
  final _InfoData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  data.value,
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

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address, required this.loading});
  final AddressResponse? address;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ADRESA ZA DOSTAVU', style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.md),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.electric,
                ),
              ),
            ),
          )
        else if (address != null) ...[
          _InfoRow(data: _InfoData(LucideIcons.mapPin, 'Ulica', address!.street)),
          _InfoRow(data: _InfoData(LucideIcons.building2, 'Grad', address!.city)),
          _InfoRow(data: _InfoData(
              LucideIcons.hash, 'Postanski broj', address!.postalCode)),
          _InfoRow(data: _InfoData(
              LucideIcons.globe, 'Drzava', address!.country)),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPinOff,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Nema sacuvane adrese',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
