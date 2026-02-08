import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/membership_package_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

/// Refactored Membership Packages Screen using Riverpod + generic patterns
class MembershipPackagesScreen extends ConsumerStatefulWidget {
  const MembershipPackagesScreen({super.key});

  @override
  ConsumerState<MembershipPackagesScreen> createState() => _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends ConsumerState<MembershipPackagesScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipPackageListProvider.notifier).load();
    });
  }

  Future<void> _addPackage() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddPackageDialog(
        onCreate: (request) async {
          await ref.read(membershipPackageListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _editPackage(MembershipPackageResponse package) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditPackageDialog(
        package: package,
        onUpdate: (request) async {
          await ref.read(membershipPackageListProvider.notifier).update(package.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    }
  }

  Future<void> _deletePackage(MembershipPackageResponse package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati paket "${package.packageName ?? ""}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(membershipPackageListProvider.notifier).delete(package.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-package'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipPackageListProvider);
    final notifier = ref.read(membershipPackageListProvider.notifier);

    return CrudListScaffold<MembershipPackageResponse, MembershipPackageQueryFilter>(
      title: 'Upravljanje paketima clanarina',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addPackage,
      searchHint: 'Pretrazi po nazivu ili opisu...',
      addButtonText: '+ Dodaj paket',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'packagename', label: 'Naziv (A-Z)'),
        SortOption(value: 'priceasc', label: 'Cijena (rastuce)'),
        SortOption(value: 'pricedesc', label: 'Cijena (opadajuce)'),
      ],
      tableBuilder: (items) => _PackagesTable(
        packages: items,
        onEdit: _editPackage,
        onDelete: _deletePackage,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PACKAGES TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int name = 3;
  static const int price = 2;
  static const int description = 4;
  static const int status = 1;
  static const int actions = 2;
}

class _PackagesTable extends StatelessWidget {
  const _PackagesTable({
    required this.packages,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MembershipPackageResponse> packages;
  final ValueChanged<MembershipPackageResponse> onEdit;
  final ValueChanged<MembershipPackageResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Naziv paketa', flex: _Flex.name),
            TableHeaderCell(text: 'Cijena', flex: _Flex.price),
            TableHeaderCell(text: 'Opis', flex: _Flex.description),
            TableHeaderCell(text: 'Status', flex: _Flex.status),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: packages.length,
      itemBuilder: (context, i) => _PackageRow(
        package: packages[i],
        isLast: i == packages.length - 1,
        onEdit: () => onEdit(packages[i]),
        onDelete: () => onDelete(packages[i]),
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({
    required this.package,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final MembershipPackageResponse package;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: package.packageName ?? '-', flex: _Flex.name),
          TableDataCell(text: '${package.packagePrice.toStringAsFixed(2)} KM', flex: _Flex.price),
          TableDataCell(
            text: (package.description?.isEmpty ?? true) ? '-' : package.description!,
            flex: _Flex.description,
          ),
          Expanded(
            flex: _Flex.status,
            child: _StatusBadge(isActive: package.isActive),
          ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isActive ? 'Aktivan' : 'Neaktivan',
          style: TextStyle(
            color: isActive ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADD PACKAGE DIALOG
// -----------------------------------------------------------------------------

class _AddPackageDialog extends StatefulWidget {
  const _AddPackageDialog({required this.onCreate});

  final Future<void> Function(CreateMembershipPackageRequest) onCreate;

  @override
  State<_AddPackageDialog> createState() => _AddPackageDialogState();
}

class _AddPackageDialogState extends State<_AddPackageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateMembershipPackageRequest(
        packageName: _nameController.text.trim(),
        packagePrice: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await widget.onCreate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String errorMessage = ErrorHandler.getContextualMessage(e, 'add-package');
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
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
                        'Dodaj paket',
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
                    label: 'Naziv paketa',
                    validator: (v) => Validators.stringLength(v, 2, 50),
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
                    label: 'Opis *',
                    maxLines: 3,
                    validator: (v) => Validators.description(v, maxLength: 500, required: true),
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
// EDIT PACKAGE DIALOG
// -----------------------------------------------------------------------------

class _EditPackageDialog extends StatefulWidget {
  const _EditPackageDialog({
    required this.package,
    required this.onUpdate,
  });

  final MembershipPackageResponse package;
  final Future<void> Function(UpdateMembershipPackageRequest) onUpdate;

  @override
  State<_EditPackageDialog> createState() => _EditPackageDialogState();
}

class _EditPackageDialogState extends State<_EditPackageDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package.packageName ?? '');
    _priceController = TextEditingController(text: widget.package.packagePrice.toString());
    _descriptionController = TextEditingController(text: widget.package.description ?? '');
    _isActive = widget.package.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateMembershipPackageRequest(
        packageName: _nameController.text.trim(),
        packagePrice: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
      );

      await widget.onUpdate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String errorMessage = ErrorHandler.getContextualMessage(e, 'edit-package');
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
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
                        'Izmijeni paket',
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
                    label: 'Naziv paketa',
                    validator: (v) => Validators.stringLength(v, 2, 50),
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
                    label: 'Opis *',
                    maxLines: 3,
                    validator: (v) => Validators.description(v, maxLength: 500, required: true),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Aktivan paket:',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeThumbColor: AppColors.accent,
                      ),
                    ],
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
