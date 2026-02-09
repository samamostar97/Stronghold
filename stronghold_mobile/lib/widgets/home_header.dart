import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import '../screens/profile_settings_screen.dart';
import '../utils/image_utils.dart';
import 'avatar_widget.dart';
import 'bottom_sheet_handle.dart';
import 'feedback_dialog.dart';

class HomeHeader extends ConsumerStatefulWidget {
  final String userName;
  final String? userImageUrl;
  final bool showSettings;

  const HomeHeader({
    super.key,
    required this.userName,
    this.userImageUrl,
    this.showSettings = true,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  late String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.userImageUrl;
  }

  String get _initials {
    final parts = widget.userName.split(' ');
    if (parts.isEmpty) return '?';
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = ref.watch(profilePictureProvider).isLoading;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: AppTextStyles.bodyMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.userName,
                style: AppTextStyles.headingLg,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (widget.showSettings) ...[
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            ),
            icon: const Icon(
              LucideIcons.settings,
              size: 22,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: isUploading ? null : _showImagePicker,
          child: isUploading
              ? _uploadingAvatar()
              : AvatarWidget(
                  initials: _initials,
                  size: 48,
                  imageUrl: _currentImageUrl != null
                      ? getFullImageUrl(_currentImageUrl)
                      : null,
                ),
        ),
      ],
    );
  }

  Widget _uploadingAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetHandle(),
          Text('Promijeni profilnu sliku', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xl),
          _pickerOption(
            LucideIcons.camera,
            'Uslikaj novu',
            () => _pick(ctx, ImageSource.camera),
          ),
          _pickerOption(
            LucideIcons.image,
            'Odaberi iz galerije',
            () => _pick(ctx, ImageSource.gallery),
          ),
          if (_currentImageUrl != null)
            _pickerOption(
              LucideIcons.trash2,
              'Ukloni sliku',
              () {
                Navigator.pop(ctx);
                _deleteImage();
              },
              color: AppColors.error,
            ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  Widget _pickerOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    final c = color ?? AppColors.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyBold.copyWith(color: c)),
      onTap: onTap,
    );
  }

  Future<void> _pick(BuildContext ctx, ImageSource source) async {
    Navigator.pop(ctx);
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      final url = await ref
          .read(profilePictureProvider.notifier)
          .upload(picked.path);
      if (mounted) {
        setState(() => _currentImageUrl = url);
        await showSuccessFeedback(context, 'Slika uspjesno promijenjena');
      }
    } catch (e) {
      if (mounted) {
        final state = ref.read(profilePictureProvider);
        await showErrorFeedback(
          context,
          state.error ?? e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _deleteImage() async {
    try {
      await ref.read(profilePictureProvider.notifier).delete();
      if (mounted) {
        setState(() => _currentImageUrl = null);
        await showSuccessFeedback(context, 'Slika uspjesno uklonjena');
      }
    } catch (e) {
      if (mounted) {
        final state = ref.read(profilePictureProvider);
        await showErrorFeedback(
          context,
          state.error ?? e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
