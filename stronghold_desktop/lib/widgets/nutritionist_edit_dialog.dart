import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'dialog_text_field.dart';

class NutritionistEditDialog extends StatefulWidget {
  const NutritionistEditDialog({
    super.key,
    required this.nutritionist,
    required this.onUpdate,
  });

  final NutritionistResponse nutritionist;
  final Future<void> Function(UpdateNutritionistRequest) onUpdate;

  @override
  State<NutritionistEditDialog> createState() => _State();
}

class _State extends State<NutritionistEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.nutritionist.firstName);
    _lastName = TextEditingController(text: widget.nutritionist.lastName);
    _email = TextEditingController(text: widget.nutritionist.email);
    _phone = TextEditingController(text: widget.nutritionist.phoneNumber);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onUpdate(UpdateNutritionistRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(
            ErrorHandler.getContextualMessage(e, 'update-nutritionist'));
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
                    Expanded(child: Text('Izmijeni nutricionistu',
                        style: AppTextStyles.headingMd)),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  Row(children: [
                    Expanded(child: DialogTextField(
                        controller: _firstName, label: 'Ime',
                        validator: (v) => Validators.name(v, fieldName: 'Ime'))),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: DialogTextField(
                        controller: _lastName, label: 'Prezime',
                        validator: (v) =>
                            Validators.name(v, fieldName: 'Prezime'))),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _email, label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _phone, label: 'Telefon',
                      hint: '061 123 456',
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone),
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
      ),
    );
  }
}
