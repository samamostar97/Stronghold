import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/supplement_category_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';

/// Refactored Categories Screen using Riverpod + generic patterns
/// Old: ~850 LOC in category_management_screen.dart | New: ~300 LOC (65% reduction)
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplementCategoryListProvider.notifier).load();
    });
  }

  Future<void> _addCategory() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCategoryDialog(),
    );

    if (created == true && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      ref.read(supplementCategoryListProvider.notifier).refresh();
    }
  }

  Future<void> _editCategory(SupplementCategoryResponse category) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditCategoryDialog(category: category),
    );

    if (updated == true && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      ref.read(supplementCategoryListProvider.notifier).refresh();
    }
  }

  Future<void> _deleteCategory(SupplementCategoryResponse category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati kategoriju "${category.name}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(supplementCategoryListProvider.notifier).delete(category.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-category'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplementCategoryListProvider);
    final notifier = ref.read(supplementCategoryListProvider.notifier);

    return CrudListScaffold<SupplementCategoryResponse, SupplementCategoryQueryFilter>(
      title: 'Upravljanje kategorijama',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addCategory,
      searchHint: 'Pretrazi po nazivu...',
      addButtonText: '+ Dodaj kategoriju',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'naziv', label: 'Naziv (A-Z)'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _CategoriesTable(
        categories: items,
        onEdit: _editCategory,
        onDelete: _deleteCategory,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORIES TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int name = 3;
  static const int actions = 2;
}

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplementCategoryResponse> categories;
  final ValueChanged<SupplementCategoryResponse> onEdit;
  final ValueChanged<SupplementCategoryResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Naziv', flex: _Flex.name),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) => _CategoryRow(
        category: categories[i],
        isLast: i == categories.length - 1,
        onEdit: () => onEdit(categories[i]),
        onDelete: () => onDelete(categories[i]),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementCategoryResponse category;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: category.name, flex: _Flex.name),
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

// -----------------------------------------------------------------------------
// ADD CATEGORY DIALOG
// -----------------------------------------------------------------------------

class _AddCategoryDialog extends ConsumerStatefulWidget {
  const _AddCategoryDialog();

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateSupplementCategoryRequest(
        name: _nameController.text.trim(),
      );

      await ref.read(supplementCategoryServiceProvider).create(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'create-category');
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
                        'Dodaj kategoriju',
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
// EDIT CATEGORY DIALOG
// -----------------------------------------------------------------------------

class _EditCategoryDialog extends ConsumerStatefulWidget {
  const _EditCategoryDialog({required this.category});

  final SupplementCategoryResponse category;

  @override
  ConsumerState<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<_EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateSupplementCategoryRequest(
        name: _nameController.text.trim(),
      );

      await ref.read(supplementCategoryServiceProvider).update(widget.category.id, request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'update-category');
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
                        'Izmijeni kategoriju',
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
