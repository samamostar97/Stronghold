import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/nutritionist_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/nutritionists_table.dart';
import '../widgets/nutritionist_add_dialog.dart';
import '../widgets/nutritionist_edit_dialog.dart';
import '../utils/error_handler.dart';

class NutritionistsScreen extends ConsumerStatefulWidget {
  const NutritionistsScreen({super.key});

  @override
  ConsumerState<NutritionistsScreen> createState() =>
      _NutritionistsScreenState();
}

class _NutritionistsScreenState extends ConsumerState<NutritionistsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionistListProvider.notifier).load();
    });
  }

  Future<void> _addNutritionist() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => NutritionistAddDialog(
        onCreate: (request) async {
          await ref.read(nutritionistListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editNutritionist(NutritionistResponse nutritionist) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => NutritionistEditDialog(
        nutritionist: nutritionist,
        onUpdate: (request) async {
          await ref
              .read(nutritionistListProvider.notifier)
              .update(nutritionist.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteNutritionist(NutritionistResponse nutritionist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati nutricionistu "${nutritionist.fullName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(nutritionistListProvider.notifier)
          .delete(nutritionist.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'delete-nutritionist'));
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
      tableBuilder: (items) => NutritionistsTable(
        nutritionists: items,
        onEdit: _editNutritionist,
        onDelete: _deleteNutritionist,
      ),
    );
  }
}
