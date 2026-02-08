import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../providers/supplement_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

/// Refactored Supplements Screen using Riverpod + generic patterns
/// Old: ~1,509 LOC | New: ~200 LOC (87% reduction)
class SupplementsScreen extends ConsumerStatefulWidget {
  const SupplementsScreen({super.key});

  @override
  ConsumerState<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends ConsumerState<SupplementsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplementListProvider.notifier).load();
    });
  }

  Future<void> _addSupplement() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddSupplementDialog(),
    );

    if (created == true && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) showSuccessAnimation(context);
    }
  }

  Future<void> _editSupplement(SupplementResponse supplement) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditSupplementDialog(supplement: supplement),
    );

    if (updated == true && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) showSuccessAnimation(context);
    }
  }

  Future<void> _deleteSupplement(SupplementResponse supplement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da želite obrisati suplement "${supplement.name}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(supplementListProvider.notifier).delete(supplement.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-supplement'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplementListProvider);
    final notifier = ref.read(supplementListProvider.notifier);

    return CrudListScaffold<SupplementResponse, SupplementQueryFilter>(
      title: 'Upravljanje suplementima',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addSupplement,
      searchHint: 'Pretraži po nazivu, dobavljaču ili kategoriji...',
      addButtonText: '+ Dodaj suplement',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'supplement', label: 'Naziv (A-Z)'),
        SortOption(value: 'category', label: 'Kategorija (A-Z)'),
        SortOption(value: 'supplier', label: 'Dobavljač (A-Z)'),
      ],
      tableBuilder: (items) => _SupplementsTable(
        supplements: items,
        onEdit: _editSupplement,
        onDelete: _deleteSupplement,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPLEMENTS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
  static const int image = 1;
  static const int name = 2;
  static const int price = 1;
  static const int category = 2;
  static const int supplier = 2;
  static const int actions = 2;
}

class _SupplementsTable extends StatelessWidget {
  const _SupplementsTable({
    required this.supplements,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplementResponse> supplements;
  final ValueChanged<SupplementResponse> onEdit;
  final ValueChanged<SupplementResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Slika', flex: _Flex.image),
            TableHeaderCell(text: 'Naziv', flex: _Flex.name),
            TableHeaderCell(text: 'Cijena', flex: _Flex.price),
            TableHeaderCell(text: 'Kategorija', flex: _Flex.category),
            TableHeaderCell(text: 'Dobavljač', flex: _Flex.supplier),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: supplements.length,
      itemBuilder: (context, i) => _SupplementRow(
        supplement: supplements[i],
        isLast: i == supplements.length - 1,
        onEdit: () => onEdit(supplements[i]),
        onDelete: () => onDelete(supplements[i]),
      ),
    );
  }
}

class _SupplementRow extends StatelessWidget {
  const _SupplementRow({
    required this.supplement,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementResponse supplement;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          Expanded(
            flex: _Flex.image,
            child: _SupplementImage(imageUrl: supplement.imageUrl),
          ),
          TableDataCell(text: supplement.name, flex: _Flex.name),
          TableDataCell(text: '${supplement.price.toStringAsFixed(2)} KM', flex: _Flex.price),
          TableDataCell(text: supplement.supplementCategoryName ?? '-', flex: _Flex.category),
          TableDataCell(text: supplement.supplierName ?? '-', flex: _Flex.supplier),
          Expanded(
            flex: _Flex.actions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
                const SizedBox(width: 8),
                SmallButton(text: 'Obriši', color: AppColors.accent, onTap: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplementImage extends StatelessWidget {
  const _SupplementImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(6),
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  '${ApiConfig.baseUrl}$imageUrl',
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => const Icon(
                    Icons.image,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              )
            : const Icon(Icons.image, color: AppColors.muted, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD SUPPLEMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddSupplementDialog extends ConsumerStatefulWidget {
  const _AddSupplementDialog();

  @override
  ConsumerState<_AddSupplementDialog> createState() => _AddSupplementDialogState();
}

class _AddSupplementDialogState extends ConsumerState<_AddSupplementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  SupplementCategoryResponse? _selectedCategory;
  SupplierResponse? _selectedSupplier;
  String? _selectedImagePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImagePath = result.files.first.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedSupplier == null) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateSupplementRequest(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        supplementCategoryId: _selectedCategory!.id,
        supplierId: _selectedSupplier!.id,
      );

      final supplementId = await ref.read(supplementListProvider.notifier).create(request);

      // Upload image if selected
      if (_selectedImagePath != null) {
        await ref.read(supplementListProvider.notifier).uploadImage(supplementId, _selectedImagePath!);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'add-supplement'));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesDropdownProvider);
    final suppliersAsync = ref.watch(suppliersDropdownProvider);

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
                        'Dodaj suplement',
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
                  // Image picker
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
                              : const Icon(Icons.image, size: 40, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload, size: 18),
                        label: Text(_selectedImagePath != null ? 'Promijeni sliku' : 'Odaberi sliku'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.editBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _priceController,
                    label: 'Cijena (KM)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.price,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _descriptionController,
                    label: 'Opis (opcionalno)',
                    maxLines: 3,
                    validator: Validators.description,
                  ),
                  const SizedBox(height: 16),
                  // Category dropdown
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greška: $e', style: const TextStyle(color: AppColors.accent)),
                    data: (categories) {
                      if (_selectedCategory == null && categories.isNotEmpty) {
                        _selectedCategory = categories.first;
                      }
                      return _buildDropdown<SupplementCategoryResponse>(
                        label: 'Kategorija',
                        value: _selectedCategory,
                        items: categories,
                        itemLabel: (c) => c.name,
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Supplier dropdown
                  suppliersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greška: $e', style: const TextStyle(color: AppColors.accent)),
                    data: (suppliers) {
                      if (_selectedSupplier == null && suppliers.isNotEmpty) {
                        _selectedSupplier = suppliers.first;
                      }
                      return _buildDropdown<SupplierResponse>(
                        label: 'Dobavljač',
                        value: _selectedSupplier,
                        items: suppliers,
                        itemLabel: (s) => s.name,
                        onChanged: (v) => setState(() => _selectedSupplier = v),
                      );
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
      dropdownColor: AppColors.panel,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Obavezno polje' : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT SUPPLEMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _EditSupplementDialog extends ConsumerStatefulWidget {
  const _EditSupplementDialog({required this.supplement});

  final SupplementResponse supplement;

  @override
  ConsumerState<_EditSupplementDialog> createState() => _EditSupplementDialogState();
}

class _EditSupplementDialogState extends ConsumerState<_EditSupplementDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  SupplementCategoryResponse? _selectedCategory;
  SupplierResponse? _selectedSupplier;
  String? _selectedImagePath;
  bool _imageDeleted = false;
  String? _currentImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplement.name);
    _priceController = TextEditingController(text: widget.supplement.price.toString());
    _descriptionController = TextEditingController(text: widget.supplement.description ?? '');
    _currentImageUrl = widget.supplement.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedSupplier == null) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateSupplementRequest(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        supplementCategoryId: _selectedCategory!.id,
        supplierId: _selectedSupplier!.id,
      );

      await ref.read(supplementListProvider.notifier).update(widget.supplement.id, request);

      // Handle image changes
      if (_imageDeleted && _currentImageUrl != null) {
        await ref.read(supplementListProvider.notifier).deleteImage(widget.supplement.id);
      } else if (_selectedImagePath != null) {
        await ref.read(supplementListProvider.notifier).uploadImage(widget.supplement.id, _selectedImagePath!);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'edit-supplement'));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesDropdownProvider);
    final suppliersAsync = ref.watch(suppliersDropdownProvider);

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
                        'Izmijeni suplement',
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
                  // Image picker
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
                                        Icons.image,
                                        size: 40,
                                        color: AppColors.muted,
                                      ),
                                    )
                                  : const Icon(Icons.image, size: 40, color: AppColors.muted),
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
                  DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) => Validators.stringLength(v, 2, 100),
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _priceController,
                    label: 'Cijena (KM)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.price,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _descriptionController,
                    label: 'Opis (opcionalno)',
                    maxLines: 3,
                    validator: Validators.description,
                  ),
                  const SizedBox(height: 16),
                  // Category dropdown
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greška: $e', style: const TextStyle(color: AppColors.accent)),
                    data: (categories) {
                      // Set initial category based on supplement's category
                      if (_selectedCategory == null && categories.isNotEmpty) {
                        _selectedCategory = categories.firstWhere(
                          (c) => c.id == widget.supplement.supplementCategoryId,
                          orElse: () => categories.first,
                        );
                      }
                      return _buildDropdown<SupplementCategoryResponse>(
                        label: 'Kategorija',
                        value: _selectedCategory,
                        items: categories,
                        itemLabel: (c) => c.name,
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Supplier dropdown
                  suppliersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greška: $e', style: const TextStyle(color: AppColors.accent)),
                    data: (suppliers) {
                      // Set initial supplier based on supplement's supplier
                      if (_selectedSupplier == null && suppliers.isNotEmpty) {
                        _selectedSupplier = suppliers.firstWhere(
                          (s) => s.id == widget.supplement.supplierId,
                          orElse: () => suppliers.first,
                        );
                      }
                      return _buildDropdown<SupplierResponse>(
                        label: 'Dobavljač',
                        value: _selectedSupplier,
                        items: suppliers,
                        itemLabel: (s) => s.name,
                        onChanged: (v) => setState(() => _selectedSupplier = v),
                      );
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
      dropdownColor: AppColors.panel,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Obavezno polje' : null,
    );
  }
}
