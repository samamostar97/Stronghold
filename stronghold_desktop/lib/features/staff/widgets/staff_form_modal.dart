import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/staff_response.dart';
import '../providers/staff_provider.dart';

class StaffFormModal extends ConsumerStatefulWidget {
  final StaffResponse? staff; // null = create, non-null = edit

  const StaffFormModal({super.key, this.staff});

  @override
  ConsumerState<StaffFormModal> createState() => _StaffFormModalState();
}

class _StaffFormModalState extends ConsumerState<StaffFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  late String _staffType;
  late bool _isActive;
  bool _loading = false;

  // Image
  String? _selectedImagePath;
  String? _selectedImageName;
  bool _uploadingImage = false;

  bool get isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.staff?.firstName ?? '');
    _lastName = TextEditingController(text: widget.staff?.lastName ?? '');
    _email = TextEditingController(text: widget.staff?.email ?? '');
    _phone = TextEditingController(text: widget.staff?.phone ?? '');
    _bio = TextEditingController(text: widget.staff?.bio ?? '');
    _staffType = widget.staff?.staffType ?? 'Trainer';
    _isActive = widget.staff?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
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

    setState(() => _loading = true);
    try {
      final repo = ref.read(staffRepositoryProvider);
      StaffResponse savedStaff;

      if (isEditing) {
        savedStaff = await repo.updateStaff(
          id: widget.staff!.id,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          staffType: _staffType,
          isActive: _isActive,
        );
      } else {
        savedStaff = await repo.createStaff(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          staffType: _staffType,
        );
      }

      // Upload image if selected
      if (_selectedImagePath != null) {
        setState(() {
          _uploadingImage = true;
        });
        await repo.uploadProfileImage(
          id: savedStaff.id,
          filePath: _selectedImagePath!,
          fileName: _selectedImageName!,
        );
      }

      ref.invalidate(staffListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Osoblje uspjesno azurirano.'
                : 'Osoblje uspjesno dodano.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
        constraints: const BoxConstraints(maxWidth: 500),
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
                        isEditing ? 'Uredi osoblje' : 'Dodaj osoblje',
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
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),

                // Profile image
                Center(child: _buildImagePicker()),
                const SizedBox(height: 20),

                // Form fields
                Row(
                  children: [
                    Expanded(child: _buildField('Ime', _firstName, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Prezime', _lastName, required: true)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildField('Email', _email, required: true, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildField('Telefon', _phone),
                const SizedBox(height: 14),
                _buildField('Bio', _bio, maxLines: 3),
                const SizedBox(height: 14),

                // Staff type
                Text('Tip', style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _TypeChip(
                      label: 'Trener',
                      isSelected: _staffType == 'Trainer',
                      onTap: () => setState(() => _staffType = 'Trainer'),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Nutricionist',
                      isSelected: _staffType == 'Nutritionist',
                      onTap: () => setState(() => _staffType = 'Nutritionist'),
                    ),
                  ],
                ),

                // IsActive toggle (only for edit)
                if (isEditing) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('Aktivan', style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                      const Spacer(),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
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
                            isEditing ? 'Sacuvaj izmjene' : 'Dodaj osoblje',
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
    final hasExistingImage = widget.staff?.profileImageUrl != null &&
        widget.staff!.profileImageUrl!.isNotEmpty;
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
                          '${ApiConstants.baseUrl.replaceAll('/api', '')}${widget.staff!.profileImageUrl!}',
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
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          style: AppTextStyles.body.copyWith(fontSize: 13),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Obavezno polje' : null
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
