import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/motion.dart';
import '../providers/nutritionist_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/nutritionists/nutritionists_table.dart';
import '../widgets/nutritionists/nutritionist_add_dialog.dart';
import '../widgets/nutritionists/nutritionist_edit_dialog.dart';
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
        showErrorAnimation(
          context,
          message:
              ErrorHandler.getContextualMessage(e, 'delete-nutritionist'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionistListProvider);
    final notifier = ref.read(nutritionistListProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              CrudListScaffold<NutritionistResponse, NutritionistQueryFilter>(
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
              SortOption(value: 'firstnamedesc', label: 'Ime (Z-A)'),
              SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
              SortOption(value: 'lastnamedesc', label: 'Prezime (Z-A)'),
              SortOption(value: 'createdat', label: 'Najstarije prvo'),
              SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
            ],
            tableBuilder: (items) => NutritionistsTable(
              nutritionists: items,
              onEdit: _editNutritionist,
              onDelete: _deleteNutritionist,
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
