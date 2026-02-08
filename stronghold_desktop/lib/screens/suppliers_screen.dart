import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/supplier_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';

/// Refactored Suppliers Screen using Riverpod + generic patterns
/// Old: ~1,043 LOC | New: ~280 LOC (73% reduction)
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierListProvider.notifier).load();
    });
  }

  Future<void> _addSupplier() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddSupplierDialog(
        onCreate: (request) async {
          await ref.read(supplierListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _editSupplier(SupplierResponse supplier) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditSupplierDialog(
        supplier: supplier,
        onUpdate: (request) async {
          await ref.read(supplierListProvider.notifier).update(supplier.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _deleteSupplier(SupplierResponse supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati dobavljaca "${supplier.name}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(supplierListProvider.notifier).delete(supplier.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-supplier'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final notifier = ref.read(supplierListProvider.notifier);

    return CrudListScaffold<SupplierResponse, SupplierQueryFilter>(
      title: 'Upravljanje dobavljacima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addSupplier,
      searchHint: 'Pretrazi po nazivu...',
      addButtonText: '+ Dodaj dobavljaca',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'naziv', label: 'Naziv (A-Z)'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _SuppliersTable(
        suppliers: items,
        onEdit: _editSupplier,
        onDelete: _deleteSupplier,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPLIERS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
  static const int name = 3;
  static const int website = 3;
  static const int actions = 2;
}

class _SuppliersTable extends StatelessWidget {
  const _SuppliersTable({
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplierResponse> suppliers;
  final ValueChanged<SupplierResponse> onEdit;
  final ValueChanged<SupplierResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Naziv', flex: _Flex.name),
            TableHeaderCell(text: 'Web stranica', flex: _Flex.website),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, i) => _SupplierRow(
        supplier: suppliers[i],
        isLast: i == suppliers.length - 1,
        onEdit: () => onEdit(suppliers[i]),
        onDelete: () => onDelete(suppliers[i]),
      ),
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({
    required this.supplier,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplierResponse supplier;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: supplier.name, flex: _Flex.name),
          TableDataCell(text: supplier.website ?? '-', flex: _Flex.website),
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

// ─────────────────────────────────────────────────────────────────────────────
// ADD SUPPLIER DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddSupplierDialog extends StatefulWidget {
  const _AddSupplierDialog({required this.onCreate});

  final Future<void> Function(CreateSupplierRequest) onCreate;

  @override
  State<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<_AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateSupplierRequest(
        name: _nameController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
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
          String errorMessage = ErrorHandler.getContextualMessage(e, 'create-supplier');
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
                        'Dodaj dobavljaca',
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
                  DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _websiteController,
                    label: 'Web stranica (opcionalno)',
                    maxLines: 1,
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

// ─────────────────────────────────────────────────────────────────────────────
// EDIT SUPPLIER DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _EditSupplierDialog extends StatefulWidget {
  const _EditSupplierDialog({
    required this.supplier,
    required this.onUpdate,
  });

  final SupplierResponse supplier;
  final Future<void> Function(UpdateSupplierRequest) onUpdate;

  @override
  State<_EditSupplierDialog> createState() => _EditSupplierDialogState();
}

class _EditSupplierDialogState extends State<_EditSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _websiteController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _websiteController = TextEditingController(text: widget.supplier.website ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateSupplierRequest(
        name: _nameController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
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
          String errorMessage = ErrorHandler.getContextualMessage(e, 'update-supplier');
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
                        'Izmijeni dobavljaca',
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
                  DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _websiteController,
                    label: 'Web stranica (opcionalno)',
                    maxLines: 1,
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
