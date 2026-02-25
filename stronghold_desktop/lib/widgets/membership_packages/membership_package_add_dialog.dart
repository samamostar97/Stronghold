import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';
import '../shared/dialog_text_field.dart';

class MembershipPackageAddDialog extends StatefulWidget {
  const MembershipPackageAddDialog({super.key, required this.onCreate});
  final Future<void> Function(CreateMembershipPackageRequest) onCreate;

  @override
  State<MembershipPackageAddDialog> createState() => _State();
}

class _State extends State<MembershipPackageAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onCreate(CreateMembershipPackageRequest(
        packageName: _name.text.trim(),
        packagePrice: double.parse(_price.text.trim()),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(
            ErrorHandler.getContextualMessage(e, 'add-package'));
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(child: Text('Dodaj paket',
                        style: AppTextStyles.headingMd)),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  DialogTextField(controller: _name, label: 'Naziv paketa',
                      validator: (v) => Validators.stringLength(v, 2, 50)),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _price, label: 'Cijena (KM)',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.price),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _description, label: 'Opis *',
                      maxLines: 3,
                      validator: (v) =>
                          Validators.description(v, maxLength: 500,
                              required: true)),
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
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                              vertical: AppSpacing.md),
                        ),
                        child: _saving
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background))
                            : Text('Dodaj',
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
      ),
    );
  }
}
