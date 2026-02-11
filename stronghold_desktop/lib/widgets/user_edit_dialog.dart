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

/// Dialog for editing an existing user.
class UserEditDialog extends ConsumerStatefulWidget {
  const UserEditDialog({super.key, required this.user});

  final UserResponse user;

  @override
  ConsumerState<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends ConsumerState<UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _username = TextEditingController(text: widget.user.username);
  late final _email = TextEditingController(text: widget.user.email);
  late final _phone = TextEditingController(text: widget.user.phoneNumber);
  final _password = TextEditingController();
  bool _saving = false;
  String? _selectedImagePath;
  bool _imageDeleted = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.user.profileImageUrl;
  }

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
      setState(() {
        _selectedImagePath = result.files.first.path;
        _imageDeleted = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
      _imageDeleted = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final request = UpdateUserRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        password:
            _password.text.isNotEmpty ? _password.text : null,
      );
      await ref
          .read(userListProvider.notifier)
          .update(widget.user.id, request);
      if (_imageDeleted && _currentImageUrl != null) {
        await ref
            .read(userListProvider.notifier)
            .deleteImage(widget.user.id);
      } else if (_selectedImagePath != null) {
        await ref
            .read(userListProvider.notifier)
            .uploadImage(widget.user.id, _selectedImagePath!);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'edit-user'));
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
                        validator: (v) =>
                            Validators.name(v, fieldName: 'Ime'))),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: DialogTextField(
                        controller: _lastName, label: 'Prezime',
                        validator: (v) =>
                            Validators.name(v, fieldName: 'Prezime'))),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _username,
                      label: 'Korisnicko ime',
                      validator: Validators.username),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _email, label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _phone, label: 'Telefon',
                      hint: '061 123 456',
                      keyboardType: TextInputType.phone,
                      validator: (v) => Validators.phone(v, required: false)),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(controller: _password,
                      label: 'Nova lozinka (ostavite prazno za zadrzavanje)',
                      obscureText: true,
                      validator: (v) =>
                          Validators.password(v, required: false)),
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
        Expanded(
            child: Text('Izmijeni korisnika',
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
                : (_currentImageUrl != null && !_imageDeleted)
                    ? Image.network(
                        ApiConfig.imageUrl(_currentImageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(LucideIcons.user,
                            size: 32, color: AppColors.textMuted),
                      )
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
            if (_currentImageUrl != null || _selectedImagePath != null)
              TextButton.icon(
                onPressed: _removeImage,
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

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
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
                horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.background))
              : Text('Spremi',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.background)),
        ),
      ],
    );
  }
}
