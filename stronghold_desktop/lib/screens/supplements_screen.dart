import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/motion.dart';
import '../providers/supplement_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/supplements/supplements_table.dart';
import '../widgets/supplements/supplement_add_dialog.dart';
import '../widgets/supplements/supplement_edit_dialog.dart';
import '../utils/error_handler.dart';

class SupplementsScreen extends ConsumerStatefulWidget {
  const SupplementsScreen({super.key});

  @override
  ConsumerState<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends ConsumerState<SupplementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplementListProvider.notifier).load();
    });
  }

  Future<void> _addSupplement() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const SupplementAddDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editSupplement(SupplementResponse supplement) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SupplementEditDialog(supplement: supplement),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteSupplement(SupplementResponse supplement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati suplement "${supplement.name}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(supplementListProvider.notifier).delete(supplement.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-supplement'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplementListProvider);
    final notifier = ref.read(supplementListProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CrudListScaffold<SupplementResponse, SupplementQueryFilter>(
            state: state,
            onRefresh: notifier.refresh,
            onSearch: notifier.setSearch,
            onSort: notifier.setOrderBy,
            onPageChanged: notifier.goToPage,
            onAdd: _addSupplement,
            searchHint: 'Pretrazi po nazivu, dobavljacu ili kategoriji...',
            addButtonText: '+ Dodaj suplement',
            sortOptions: const [
              SortOption(value: null, label: 'Zadano'),
              SortOption(value: 'name', label: 'Naziv (A-Z)'),
              SortOption(value: 'namedesc', label: 'Naziv (Z-A)'),
              SortOption(value: 'category', label: 'Kategorija (A-Z)'),
              SortOption(value: 'categorydesc', label: 'Kategorija (Z-A)'),
              SortOption(value: 'supplier', label: 'Dobavljac (A-Z)'),
              SortOption(value: 'supplierdesc', label: 'Dobavljac (Z-A)'),
              SortOption(value: 'price', label: 'Cijena rastuce'),
              SortOption(value: 'pricedesc', label: 'Cijena opadajuce'),
              SortOption(value: 'createdat', label: 'Najstarije prvo'),
              SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
            ],
            tableBuilder: (items) => SupplementsTable(
              supplements: items,
              onEdit: _editSupplement,
              onDelete: _deleteSupplement,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }
}
