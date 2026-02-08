import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

/// Refactored Users Screen using Riverpod + generic patterns
/// Old: ~1,275 LOC | New: ~350 LOC (73% reduction)
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).load();
    });
  }

  Future<void> _addUser() async {
    final created = await showDialog<Object?>(
      context: context,
      builder: (_) => const _AddUserDialog(),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    } else if (created is String && mounted) {
      showErrorAnimation(context, message: created);
    }
  }

  Future<void> _editUser(UserResponse user) async {
    final updated = await showDialog<Object?>(
      context: context,
      builder: (_) => _EditUserDialog(user: user),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    } else if (updated is String && mounted) {
      showErrorAnimation(context, message: updated);
    }
  }

  Future<void> _deleteUser(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati korisnika "${user.username}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(userListProvider.notifier).delete(user.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-user'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return CrudListScaffold<UserResponse, UserQueryFilter>(
      title: 'Upravljanje korisnicima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addUser,
      searchHint: 'Pretrazi korisnike...',
      addButtonText: '+ Dodaj korisnika',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'firstname', label: 'Ime (A-Z)'),
        SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
        SortOption(value: 'datedesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _UsersTable(
        users: items,
        onEdit: _editUser,
        onDelete: _deleteUser,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// USERS TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int image = 1;
  static const int username = 2;
  static const int firstName = 2;
  static const int lastName = 2;
  static const int email = 3;
  static const int phone = 2;
  static const int actions = 2;
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserResponse> users;
  final ValueChanged<UserResponse> onEdit;
  final ValueChanged<UserResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: '', flex: _Flex.image),
            TableHeaderCell(text: 'Korisnicko ime', flex: _Flex.username),
            TableHeaderCell(text: 'Ime', flex: _Flex.firstName),
            TableHeaderCell(text: 'Prezime', flex: _Flex.lastName),
            TableHeaderCell(text: 'Email', flex: _Flex.email),
            TableHeaderCell(text: 'Telefon', flex: _Flex.phone),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: users.length,
      itemBuilder: (context, i) => _UserRow(
        user: users[i],
        index: i,
        isLast: i == users.length - 1,
        onEdit: () => onEdit(users[i]),
        onDelete: () => onDelete(users[i]),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.index,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final UserResponse user;
  final int index;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      index: index,
      child: Row(
        children: [
          Expanded(
            flex: _Flex.image,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipOval(
                  child: user.profileImageUrl != null
                      ? Image.network(
                          ApiConfig.imageUrl(user.profileImageUrl!),
                          fit: BoxFit.cover,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.muted,
                          ),
                        )
                      : const Icon(Icons.person, size: 18, color: AppColors.muted),
                ),
              ),
            ),
          ),
          TableDataCell(text: user.username, flex: _Flex.username, bold: true),
          TableDataCell(text: user.firstName, flex: _Flex.firstName),
          TableDataCell(text: user.lastName, flex: _Flex.lastName),
          TableDataCell(text: user.email, flex: _Flex.email, muted: true),
          TableDataCell(text: user.phoneNumber, flex: _Flex.phone, muted: true),
          TableActionCell(
            flex: _Flex.actions,
            children: [
              SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
              const SizedBox(width: 8),
              SmallButton(text: 'Obrisi', color: AppColors.accent, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD USER DIALOG
// -----------------------------------------------------------------------------

class _AddUserDialog extends ConsumerStatefulWidget {
  const _AddUserDialog();

  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedGender = 0; // 0 = Male, 1 = Female, 2 = Other
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateUserRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        password: _passwordController.text,
      );

      await ref.read(userListProvider.notifier).create(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(ErrorHandler.getContextualMessage(e, 'add-user'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dodaj korisnika',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) => Validators.name(v, fieldName: 'Ime'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) => Validators.name(v, fieldName: 'Prezime'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _usernameController,
                    label: 'Korisnicko ime',
                    validator: Validators.username,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _passwordController,
                    label: 'Lozinka',
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  _GenderDropdown(
                    value: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Dodaj'),
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

// -----------------------------------------------------------------------------
// EDIT USER DIALOG
// -----------------------------------------------------------------------------

class _EditUserDialog extends ConsumerStatefulWidget {
  const _EditUserDialog({required this.user});

  final UserResponse user;

  @override
  ConsumerState<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _isSaving = false;
  String? _selectedImagePath;
  bool _imageDeleted = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _passwordController = TextEditingController();
    _currentImageUrl = widget.user.profileImageUrl;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateUserRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      await ref.read(userListProvider.notifier).update(widget.user.id, request);

      // Handle image changes
      if (_imageDeleted && _currentImageUrl != null) {
        await ref.read(userListProvider.notifier).deleteImage(widget.user.id);
      } else if (_selectedImagePath != null) {
        await ref.read(userListProvider.notifier).uploadImage(widget.user.id, _selectedImagePath!);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(ErrorHandler.getContextualMessage(e, 'edit-user'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Izmijeni korisnika',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile image section
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedImagePath != null
                              ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                              : (_currentImageUrl != null && !_imageDeleted)
                                  ? Image.network(
                                      ApiConfig.imageUrl(_currentImageUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.muted,
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 40, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload, size: 18),
                            label: Text(_selectedImagePath != null ? 'Promijeni sliku' : 'Odaberi sliku'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.editBlue),
                          ),
                          if (_currentImageUrl != null || _selectedImagePath != null)
                            TextButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Ukloni sliku'),
                              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) => Validators.name(v, fieldName: 'Ime'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) => Validators.name(v, fieldName: 'Prezime'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _usernameController,
                    label: 'Korisnicko ime',
                    validator: Validators.username,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.phone(v, required: false),
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _passwordController,
                    label: 'Nova lozinka (ostavite prazno za zadrzavanje)',
                    obscureText: true,
                    validator: (v) => Validators.password(v, required: false),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
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

// -----------------------------------------------------------------------------
// SHARED WIDGETS
// -----------------------------------------------------------------------------

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      onChanged: (v) => onChanged(v ?? 0),
      dropdownColor: AppColors.panel,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Spol',
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        filled: true,
        fillColor: AppColors.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: const [
        DropdownMenuItem<int>(value: 0, child: Text('Muski')),
        DropdownMenuItem<int>(value: 1, child: Text('Zenski')),
        DropdownMenuItem<int>(value: 2, child: Text('Ostalo')),
      ],
    );
  }
}
