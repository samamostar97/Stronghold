import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/supplier_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/suppliers_table.dart';
import '../widgets/supplier_dialog.dart';
import '../utils/error_handler.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplierListProvider.notifier).load();
    });
  }

  Future<void> _addSupplier() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SupplierDialog(
        onSave: (name, website) async {
          await ref.read(supplierListProvider.notifier).create(
                CreateSupplierRequest(name: name, website: website),
              );
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editSupplier(SupplierResponse supplier) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SupplierDialog(
        initial: supplier,
        onSave: (name, website) async {
          await ref.read(supplierListProvider.notifier).update(
                supplier.id,
                UpdateSupplierRequest(name: name, website: website),
              );
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteSupplier(SupplierResponse supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati dobavljaca "${supplier.name}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(supplierListProvider.notifier).delete(supplier.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-supplier'));
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
      tableBuilder: (items) => SuppliersTable(
        suppliers: items,
        onEdit: _editSupplier,
        onDelete: _deleteSupplier,
      ),
    );
  }
}
