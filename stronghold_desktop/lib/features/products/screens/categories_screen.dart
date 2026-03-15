import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/product_category_response.dart';
import '../providers/products_provider.dart';
import '../widgets/category_form_modal.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openCreateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CategoryFormModal(),
    );
  }

  void _openEditModal(BuildContext context, ProductCategoryResponse category) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormModal(category: category),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ProductCategoryResponse category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Obrisi kategoriju', style: AppTextStyles.h3),
        content: Text(
          'Da li ste sigurni da zelite obrisati "${category.name}"?',
          style: AppTextStyles.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Otkazi',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = ref.read(productCategoriesRepositoryProvider);
                await repo.deleteCategory(category.id);
                ref.invalidate(categoriesListProvider);
                if (context.mounted) {
                  AppSnackbar.success(context, '"${category.name}" je obrisana.');
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.error(context, 'Greska: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Obrisi', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Kategorije', style: AppTextStyles.h2)),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => _openCreateModal(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Dodaj kategoriju',
                      style: AppTextStyles.button.copyWith(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          categoriesAsync.when(
            loading: () => Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            error: (e, _) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Greska pri ucitavanju kategorija',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(categoriesListProvider),
                      child: Text('Pokusaj ponovo',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
            data: (categories) => _CategoriesTable(
              categories: categories,
              onEdit: (cat) => _openEditModal(context, cat),
              onDelete: (cat) => _confirmDelete(context, ref, cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTable extends StatefulWidget {
  final List<ProductCategoryResponse> categories;
  final ValueChanged<ProductCategoryResponse>? onEdit;
  final ValueChanged<ProductCategoryResponse>? onDelete;

  const _CategoriesTable({
    required this.categories,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_CategoriesTable> createState() => _CategoriesTableState();
}

class _CategoriesTableState extends State<_CategoriesTable> {
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                    width: 50,
                    child: Text('ID',
                        style: AppTextStyles.label.copyWith(fontSize: 11))),
                Expanded(
                    flex: 2,
                    child: Text('Naziv',
                        style: AppTextStyles.label.copyWith(fontSize: 11))),
                Expanded(
                    flex: 3,
                    child: Text('Opis',
                        style: AppTextStyles.label.copyWith(fontSize: 11))),
                const SizedBox(width: 80),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

          if (widget.categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child:
                    Text('Nema kategorija', style: AppTextStyles.bodySmall),
              ),
            )
          else
            ...widget.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final isHovered = _hoveredRow == index;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredRow = index),
                onExit: (_) => setState(() => _hoveredRow = null),
                child: Container(
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          '#${cat.id}',
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13, color: AppColors.primary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          cat.name,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          cat.description ?? '-',
                          style:
                              AppTextStyles.body.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  widget.onEdit?.call(cat),
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.textSecondary,
                                  size: 16),
                              tooltip: 'Uredi',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            ),
                            IconButton(
                              onPressed: () =>
                                  widget.onDelete?.call(cat),
                              icon: Icon(Icons.delete_outlined,
                                  color: AppColors.error
                                      .withValues(alpha: 0.7),
                                  size: 16),
                              tooltip: 'Obrisi',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
