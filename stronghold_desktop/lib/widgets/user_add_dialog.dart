import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/user_provider.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'dialog_text_field.dart';

/// Dialog for adding a new user.
class UserAddDialog extends ConsumerStatefulWidget {
  const UserAddDialog({super.key});

  @override
  ConsumerState<UserAddDialog> createState() => _UserAddDialogState();
}

class _UserAddDialogState extends ConsumerState<UserAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  int _gender = 0;
  String? _selectedImagePath;
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedImagePath = result.files.first.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final request = CreateUserRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        gender: _gender,
        password: _password.text,
      );
      final userId =
          await ref.read(userListProvider.notifier).create(request);
      if (_selectedImagePath != null) {
        try {
          await ref
              .read(userListProvider.notifier)
              .uploadImage(userId, _selectedImagePath!);
        } catch (_) {
          // user created but image upload failed
          if (mounted) Navigator.of(context).pop(true);
          return;
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'add-user'));
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
                  _header(),
                  const SizedBox(height: AppSpacing.xl),
                  _imageSection(),
                  const SizedBox(height: AppSpacing.lg),
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
                  DialogTextField(controller: _username, label: 'Korisnicko ime',
                      validator: Validators.username),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _email, label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _phone, label: 'Telefon',
                      hint: '061 123 456',
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _password, label: 'Lozinka',
                      obscureText: true, validator: Validators.password),
                  const SizedBox(height: AppSpacing.lg),
                  _genderDropdown(),
                  const SizedBox(height: AppSpacing.xxl),
                  _actions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(child: Text('Dodaj korisnika',
            style: AppTextStyles.headingMd)),
        IconButton(
          icon: Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Widget _imageSection() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: _selectedImagePath != null
                ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                : Icon(LucideIcons.user,
                    size: 32, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(LucideIcons.upload, size: 16),
              label: Text(_selectedImagePath != null
                  ? 'Promijeni sliku'
                  : 'Odaberi sliku'),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.secondary),
            ),
            if (_selectedImagePath != null)
              TextButton.icon(
                onPressed: () =>
                    setState(() => _selectedImagePath = null),
                icon: Icon(LucideIcons.trash2, size: 16),
                label: const Text('Ukloni sliku'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
          ],
        ),
      ],
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _gender,
      onChanged: (v) => setState(() => _gender = v ?? 0),
      dropdownColor: AppColors.surfaceSolid,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Spol',
        labelStyle: AppTextStyles.bodySm,
        filled: true,
        fillColor: AppColors.surfaceSolid,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Muski')),
        DropdownMenuItem(value: 1, child: Text('Zenski')),
        DropdownMenuItem(value: 2, child: Text('Ostalo')),
      ],
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text('Odustani',
              style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textMuted)),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.background))
              : Text('Dodaj', style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.background)),
        ),
      ],
    );
  }
}
