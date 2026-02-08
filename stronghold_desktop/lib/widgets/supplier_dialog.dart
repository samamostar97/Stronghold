import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../utils/error_handler.dart';
import 'dialog_text_field.dart';

/// Add / Edit dialog for suppliers. Pass [initial] to edit.
class SupplierDialog extends StatefulWidget {
  const SupplierDialog({
    super.key,
    this.initial,
    required this.onSave,
  });

  final SupplierResponse? initial;
  final Future<void> Function(String name, String? website) onSave;

  @override
  State<SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<SupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _website;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _website = TextEditingController(text: widget.initial?.website ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final web = _website.text.trim().isEmpty ? null : _website.text.trim();
      await widget.onSave(_name.text.trim(), web);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(
            ErrorHandler.getContextualMessage(e, 'supplier'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
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
                Row(children: [
                  Expanded(child: Text(
                      _isEdit ? 'Izmijeni dobavljaca' : 'Dodaj dobavljaca',
                      style: AppTextStyles.headingMd)),
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                DialogTextField(
                  controller: _name,
                  label: 'Naziv',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obavezno polje' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                DialogTextField(
                  controller: _website,
                  label: 'Web stranica (opcionalno)',
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text('Odustani',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.md),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.background))
                          : Text('Spremi',
                              style: AppTextStyles.bodyBold
                                  .copyWith(color: AppColors.background)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
