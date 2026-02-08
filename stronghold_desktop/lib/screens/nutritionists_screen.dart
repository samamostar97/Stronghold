import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/nutritionist_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';

/// Refactored Nutritionists Screen using Riverpod + generic patterns
/// Old: ~950 LOC | New: ~350 LOC (63% reduction)
class NutritionistsScreen extends ConsumerStatefulWidget {
  const NutritionistsScreen({super.key});

  @override
  ConsumerState<NutritionistsScreen> createState() => _NutritionistsScreenState();
}

class _NutritionistsScreenState extends ConsumerState<NutritionistsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionistListProvider.notifier).load();
    });
  }

  Future<void> _addNutritionist() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddNutritionistDialog(
        onCreate: (request) async {
          await ref.read(nutritionistListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _editNutritionist(NutritionistResponse nutritionist) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditNutritionistDialog(
        nutritionist: nutritionist,
        onUpdate: (request) async {
          await ref.read(nutritionistListProvider.notifier).update(nutritionist.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _deleteNutritionist(NutritionistResponse nutritionist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati nutricionistu "${nutritionist.fullName}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(nutritionistListProvider.notifier).delete(nutritionist.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-nutritionist'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionistListProvider);
    final notifier = ref.read(nutritionistListProvider.notifier);

    return CrudListScaffold<NutritionistResponse, NutritionistQueryFilter>(
      title: 'Upravljanje nutricionistima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addNutritionist,
      searchHint: 'Pretrazi po imenu ili prezimenu...',
      addButtonText: '+ Dodaj nutricionistu',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'firstname', label: 'Ime (A-Z)'),
        SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _NutritionistsTable(
        nutritionists: items,
        onEdit: _editNutritionist,
        onDelete: _deleteNutritionist,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NUTRITIONISTS TABLE
// ---------------------------------------------------------------------------

abstract class _Flex {
  static const int firstName = 2;
  static const int lastName = 2;
  static const int email = 2;
  static const int phone = 2;
  static const int actions = 2;
}

class _NutritionistsTable extends StatelessWidget {
  const _NutritionistsTable({
    required this.nutritionists,
    required this.onEdit,
    required this.onDelete,
  });

  final List<NutritionistResponse> nutritionists;
  final ValueChanged<NutritionistResponse> onEdit;
  final ValueChanged<NutritionistResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Ime', flex: _Flex.firstName),
            TableHeaderCell(text: 'Prezime', flex: _Flex.lastName),
            TableHeaderCell(text: 'Email', flex: _Flex.email),
            TableHeaderCell(text: 'Broj telefona', flex: _Flex.phone),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: nutritionists.length,
      itemBuilder: (context, i) => _NutritionistRow(
        nutritionist: nutritionists[i],
        isLast: i == nutritionists.length - 1,
        onEdit: () => onEdit(nutritionists[i]),
        onDelete: () => onDelete(nutritionists[i]),
      ),
    );
  }
}

class _NutritionistRow extends StatelessWidget {
  const _NutritionistRow({
    required this.nutritionist,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final NutritionistResponse nutritionist;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: nutritionist.firstName, flex: _Flex.firstName),
          TableDataCell(text: nutritionist.lastName, flex: _Flex.lastName),
          TableDataCell(text: nutritionist.email, flex: _Flex.email),
          TableDataCell(text: nutritionist.phoneNumber, flex: _Flex.phone),
          Expanded(
            flex: _Flex.actions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
                const SizedBox(width: 8),
                SmallButton(text: 'Obrisi', color: AppColors.accent, onTap: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ADD NUTRITIONIST DIALOG
// ---------------------------------------------------------------------------

class _AddNutritionistDialog extends StatefulWidget {
  const _AddNutritionistDialog({required this.onCreate});

  final Future<void> Function(CreateNutritionistRequest request) onCreate;

  @override
  State<_AddNutritionistDialog> createState() => _AddNutritionistDialogState();
}

class _AddNutritionistDialogState extends State<_AddNutritionistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateNutritionistRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await widget.onCreate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'create-nutritionist');
          showErrorAnimation(context, message: errorMessage);
        }
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
                        'Dodaj nutricionistu',
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
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      final phoneRegex = RegExp(r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$');
                      if (!phoneRegex.hasMatch(v)) return 'Format: 061 123 456';
                      return null;
                    },
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

// ---------------------------------------------------------------------------
// EDIT NUTRITIONIST DIALOG
// ---------------------------------------------------------------------------

class _EditNutritionistDialog extends StatefulWidget {
  const _EditNutritionistDialog({
    required this.nutritionist,
    required this.onUpdate,
  });

  final NutritionistResponse nutritionist;
  final Future<void> Function(UpdateNutritionistRequest request) onUpdate;

  @override
  State<_EditNutritionistDialog> createState() => _EditNutritionistDialogState();
}

class _EditNutritionistDialogState extends State<_EditNutritionistDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.nutritionist.firstName);
    _lastNameController = TextEditingController(text: widget.nutritionist.lastName);
    _emailController = TextEditingController(text: widget.nutritionist.email);
    _phoneController = TextEditingController(text: widget.nutritionist.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateNutritionistRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await widget.onUpdate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'update-nutritionist');
          showErrorAnimation(context, message: errorMessage);
        }
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
                        'Izmijeni nutricionistu',
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
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    hint: '061 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      final phoneRegex = RegExp(r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$');
                      if (!phoneRegex.hasMatch(v)) return 'Format: 061 123 456';
                      return null;
                    },
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
