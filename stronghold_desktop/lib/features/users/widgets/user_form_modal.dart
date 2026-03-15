import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/users_repository.dart';
import '../models/user_response.dart';
import '../providers/users_provider.dart';

class UserFormModal extends ConsumerStatefulWidget {
  final UserResponse? user; // null = create, non-null = edit

  const UserFormModal({super.key, this.user});

  @override
  ConsumerState<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends ConsumerState<UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _password;
  bool _loading = false;
  Map<String, String> _fieldErrors = {};
  String? _errorMessage;

  // Image
  String? _selectedImagePath;
  String? _selectedImageName;
  bool _uploadingImage = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user?.firstName ?? '');
    _lastName = TextEditingController(text: widget.user?.lastName ?? '');
    _username = TextEditingController(text: widget.user?.username ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _phone = TextEditingController(text: widget.user?.phone ?? '');
    _address = TextEditingController(text: widget.user?.address ?? '');
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _fieldErrors = {};
      _errorMessage = null;
    });
    try {
      final repo = ref.read(usersRepositoryProvider);
      UserResponse savedUser;

      if (isEditing) {
        savedUser = await repo.updateUser(
          id: widget.user!.id,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        );
      } else {
        savedUser = await repo.createUser(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        );
      }

      // Upload image if selected
      if (_selectedImagePath != null) {
        setState(() {
          _uploadingImage = true;
        });
        await repo.uploadProfileImage(
          id: savedUser.id,
          filePath: _selectedImagePath!,
          fileName: _selectedImageName!,
        );
      }

      ref.invalidate(usersListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, isEditing
            ? 'Korisnik uspjesno azuriran.'
            : 'Korisnik uspjesno dodan.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is ApiException && e.hasFieldErrors) {
            _fieldErrors = e.fieldErrors;
            _formKey.currentState!.validate();
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _uploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Uredi korisnika' : 'Dodaj korisnika',
                          style: AppTextStyles.h2,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(
                      color: Colors.white.withValues(alpha: 0.06), height: 1),
                  const SizedBox(height: 20),

                  // Profile image
                  Center(child: _buildImagePicker()),
                  const SizedBox(height: 20),

                  // Form fields
                  Row(
                    children: [
                      Expanded(
                          child: _buildField('Ime', _firstName,
                              fieldKey: 'firstName', required: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildField('Prezime', _lastName,
                              fieldKey: 'lastName', required: true)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _buildField('Username', _username,
                              fieldKey: 'username', required: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildField('Email', _email,
                              fieldKey: 'email',
                              required: true,
                              keyboardType: TextInputType.emailAddress)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!isEditing) ...[
                    _buildField('Lozinka', _password,
                        fieldKey: 'password', required: true, obscure: true),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      Expanded(
                          child: _buildField('Telefon', _phone,
                              fieldKey: 'phone')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildField('Adresa', _address,
                              fieldKey: 'address')),
                    ],
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_uploadingImage) ...[
                                  const SizedBox(width: 10),
                                  Text('Uploading slika...',
                                      style: AppTextStyles.button),
                                ],
                              ],
                            )
                          : Text(
                              isEditing
                                  ? 'Sacuvaj izmjene'
                                  : 'Dodaj korisnika',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasExistingImage = widget.user?.profileImageUrl != null &&
        widget.user!.profileImageUrl!.isNotEmpty;
    final hasSelectedImage = _selectedImagePath != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasSelectedImage
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: hasSelectedImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imageIcon(),
                    ),
                  )
                : hasExistingImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          '${ApiConstants.baseUrl.replaceAll('/api', '')}${widget.user!.profileImageUrl!}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imageIcon(),
                        ),
                      )
                    : _imageIcon(),
          ),
          const SizedBox(height: 8),
          Text(
            hasSelectedImage
                ? _selectedImageName!
                : hasExistingImage
                    ? 'Promijeni sliku'
                    : 'Dodaj sliku',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageIcon() {
    return const Center(
      child: Icon(
        Icons.camera_alt_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? fieldKey,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscure,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          onChanged: fieldKey != null && _fieldErrors.containsKey(fieldKey)
              ? (_) => setState(() => _fieldErrors.remove(fieldKey))
              : null,
          validator: (v) {
            if (required && (v == null || v.trim().isEmpty)) {
              return 'Obavezno polje';
            }
            if (fieldKey != null && _fieldErrors.containsKey(fieldKey)) {
              return _fieldErrors[fieldKey];
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
