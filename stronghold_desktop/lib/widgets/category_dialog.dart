import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/supplement_category_provider.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'dialog_text_field.dart';

/// Add / Edit dialog for categories. Pass [initial] to edit.
class CategoryDialog extends ConsumerStatefulWidget {
  const CategoryDialog({super.key, this.initial});
  final SupplementCategoryResponse? initial;

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final svc = ref.read(supplementCategoryServiceProvider);
      if (_isEdit) {
        await svc.update(
          widget.initial!.id,
          UpdateSupplementCategoryRequest(name: _name.text.trim()),
        );
      } else {
        await svc.create(
          CreateSupplementCategoryRequest(name: _name.text.trim()),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(
          context,
        ).pop(ErrorHandler.getContextualMessage(e, 'category'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: AppSpacing.xl),
                DialogTextField(
                  controller: _name,
                  label: 'Naziv',
                  validator: (v) => Validators.stringLength(v, 2, 100),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
    children: [
      Expanded(
        child: Text(
          _isEdit ? 'Izmijeni kategoriju' : 'Dodaj kategoriju',
          style: AppTextStyles.headingMd,
        ),
      ),
      IconButton(
        icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ],
  );

  Widget _actions() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        child: Text(
          'Odustani',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : Text(
                'Spremi',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.background,
                ),
              ),
      ),
    ],
  );
}
