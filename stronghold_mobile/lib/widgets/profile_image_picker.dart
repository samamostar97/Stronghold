import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import '../utils/error_handler.dart';
import 'bottom_sheet_handle.dart';
import 'feedback_dialog.dart';

/// Shows a bottom sheet for picking/removing profile image.
/// [currentImageUrl] is the current image URL (null if no image).
/// [onChanged] is called with the new URL (or null if removed).
void showProfileImagePicker({
  required BuildContext context,
  required WidgetRef ref,
  required String? currentImageUrl,
  required void Function(String? newUrl) onChanged,
}) {
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
        _PickerOption(
          icon: LucideIcons.camera,
          label: 'Uslikaj novu',
          onTap: () => _pick(ctx, context, ref, ImageSource.camera, onChanged),
        ),
        _PickerOption(
          icon: LucideIcons.image,
          label: 'Odaberi iz galerije',
          onTap: () =>
              _pick(ctx, context, ref, ImageSource.gallery, onChanged),
        ),
        if (currentImageUrl != null)
          _PickerOption(
            icon: LucideIcons.trash2,
            label: 'Ukloni sliku',
            color: AppColors.error,
            onTap: () {
              Navigator.pop(ctx);
              _delete(context, ref, onChanged);
            },
          ),
        const SizedBox(height: AppSpacing.sm),
      ]),
    ),
  );
}

Future<void> _pick(
  BuildContext sheetCtx,
  BuildContext parentCtx,
  WidgetRef ref,
  ImageSource source,
  void Function(String? newUrl) onChanged,
) async {
  Navigator.pop(sheetCtx);
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );
  if (picked == null) return;
  try {
    final url =
        await ref.read(profilePictureProvider.notifier).upload(picked.path);
    onChanged(url);
    if (parentCtx.mounted) {
      await showSuccessFeedback(parentCtx, 'Slika uspjesno promijenjena');
    }
  } catch (e) {
    if (parentCtx.mounted) {
      final state = ref.read(profilePictureProvider);
      await showErrorFeedback(
        parentCtx,
        state.error ?? ErrorHandler.message(e),
      );
    }
  }
}

Future<void> _delete(
  BuildContext parentCtx,
  WidgetRef ref,
  void Function(String? newUrl) onChanged,
) async {
  try {
    await ref.read(profilePictureProvider.notifier).delete();
    onChanged(null);
    if (parentCtx.mounted) {
      await showSuccessFeedback(parentCtx, 'Slika uspjesno uklonjena');
    }
  } catch (e) {
    if (parentCtx.mounted) {
      final state = ref.read(profilePictureProvider);
      await showErrorFeedback(
        parentCtx,
        state.error ?? ErrorHandler.message(e),
      );
    }
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
