import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/api_providers.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'avatar_widget.dart';
import 'gradient_button.dart';

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
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black54),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _body(),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final user = widget.user;
    final initials = _initials(user.firstName, user.lastName);

    return Container(
      width: 400,
      color: AppColors.surfaceSolid,
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(LucideIcons.x,
                    color: AppColors.textMuted, size: 20),
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + name + email
                    Center(
                      child: user.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              child: Image.network(
                                ApiConfig.imageUrl(user.profileImageUrl!),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    AvatarWidget(initials: initials, size: 72),
                              ),
                            )
                          : AvatarWidget(initials: initials, size: 72),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(user.fullName,
                          style: AppTextStyles.headingMd,
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(user.email,
                          style: AppTextStyles.bodySm,
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Personal info section
                    _sectionLabel('LICNI PODACI'),
                    const SizedBox(height: AppSpacing.md),
                    _infoRow(LucideIcons.user, 'Korisnicko ime', user.username),
                    _infoRow(LucideIcons.phone, 'Telefon', user.phoneNumber),
                    _infoRow(LucideIcons.users, 'Spol', user.genderDisplay),
                    const SizedBox(height: AppSpacing.xxl),

                    // Address section
                    _sectionLabel('ADRESA ZA DOSTAVU'),
                    const SizedBox(height: AppSpacing.md),
                    if (_loadingAddress)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else if (_address != null) ...[
                      _infoRow(LucideIcons.mapPin, 'Ulica', _address!.street),
                      _infoRow(LucideIcons.building2, 'Grad', _address!.city),
                      _infoRow(LucideIcons.hash, 'Postanski broj', _address!.postalCode),
                      _infoRow(LucideIcons.globe, 'Drzava', _address!.country),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(LucideIcons.mapPinOff,
                                size: 16, color: AppColors.textMuted),
                            const SizedBox(width: AppSpacing.md),
                            Text('Nema sacuvane adrese',
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.onEdit != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: GradientButton(text: 'Uredi', onTap: widget.onEdit!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.badge.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
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
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMd,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
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
