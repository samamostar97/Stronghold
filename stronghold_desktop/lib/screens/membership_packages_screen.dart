import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/membership_package_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/membership_packages/membership_packages_table.dart';
import '../widgets/membership_packages/membership_package_add_dialog.dart';
import '../widgets/membership_packages/membership_package_edit_dialog.dart';
import '../utils/error_handler.dart';

class MembershipPackagesScreen extends ConsumerStatefulWidget {
  const MembershipPackagesScreen({super.key});

  @override
  ConsumerState<MembershipPackagesScreen> createState() =>
      _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState
    extends ConsumerState<MembershipPackagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipPackageListProvider.notifier).load();
    });
  }

  Future<void> _addPackage() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => MembershipPackageAddDialog(
        onCreate: (request) async {
          await ref
              .read(membershipPackageListProvider.notifier)
              .create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editPackage(MembershipPackageResponse package) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => MembershipPackageEditDialog(
        package: package,
        onUpdate: (request) async {
          await ref
              .read(membershipPackageListProvider.notifier)
              .update(package.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deletePackage(MembershipPackageResponse package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati paket "${package.packageName ?? ""}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(membershipPackageListProvider.notifier).delete(package.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-package'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipPackageListProvider);
    final notifier = ref.read(membershipPackageListProvider.notifier);

    return CrudListScaffold<
      MembershipPackageResponse,
      MembershipPackageQueryFilter
    >(
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
        SortOption(value: 'packagenamedesc', label: 'Naziv (Z-A)'),
        SortOption(value: 'priceasc', label: 'Cijena (rastuce)'),
        SortOption(value: 'pricedesc', label: 'Cijena (opadajuce)'),
        SortOption(value: 'createdat', label: 'Najstarije prvo'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => MembershipPackagesTable(
        packages: items,
        onEdit: _editPackage,
        onDelete: _deletePackage,
      ),
    );
  }
}
