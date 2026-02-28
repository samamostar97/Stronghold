import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/motion.dart';
import '../providers/supplement_category_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../widgets/categories/category_dialog.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/small_button.dart';
import '../utils/error_handler.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supplementCategoryListProvider.notifier).load();
    });
  }

  Future<void> _addCategory() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const CategoryDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.read(supplementCategoryListProvider.notifier).refresh();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editCategory(SupplementCategoryResponse category) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => CategoryDialog(initial: category),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.read(supplementCategoryListProvider.notifier).refresh();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteCategory(SupplementCategoryResponse category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati kategoriju "${category.name}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(supplementCategoryListProvider.notifier)
          .delete(category.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-category'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplementCategoryListProvider);
    final notifier = ref.read(supplementCategoryListProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CrudListScaffold<SupplementCategoryResponse,
              SupplementCategoryQueryFilter>(
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
              SortOption(value: 'name', label: 'Naziv (A-Z)'),
              SortOption(value: 'namedesc', label: 'Naziv (Z-A)'),
              SortOption(value: 'createdat', label: 'Najstarije prvo'),
              SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
            ],
            tableBuilder: (items) => GenericDataTable<SupplementCategoryResponse>(
              items: items,
              columns: [
                ColumnDef.text(label: 'Naziv', flex: 3, value: (c) => c.name, bold: true),
                ColumnDef.actions(flex: 2, builder: (c) => [
                  SmallButton(text: 'Izmijeni', color: AppColors.secondary, onTap: () => _editCategory(c)),
                  const SizedBox(width: AppSpacing.sm),
                  SmallButton(text: 'Obrisi', color: AppColors.error, onTap: () => _deleteCategory(c)),
                ]),
              ],
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
