import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/motion.dart';
import '../providers/supplement_provider.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/small_button.dart';
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

    return CrudListScaffold<SupplementResponse, SupplementQueryFilter>(
          state: state,
          onRefresh: notifier.refresh,
          onSearch: notifier.setSearch,
          onSort: notifier.setOrderBy,
          onPageChanged: notifier.goToPage,
          onAdd: _addSupplement,
          searchHint: 'Pretrazi po nazivu, dobavljacu ili kategoriji...',
          addButtonText: '+ Dodaj suplement',
          loadingColumnFlex: const [1, 2, 1, 1, 2, 2, 2],
          sortOptions: const [
            SortOption(value: null, label: 'Zadano (stanje rastuce)'),
            SortOption(value: 'stock', label: 'Stanje rastuce'),
            SortOption(value: 'stockdesc', label: 'Stanje opadajuce'),
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
          tableBuilder: (items) => GenericDataTable<SupplementResponse>(
            items: items,
            columns: [
              ColumnDef<SupplementResponse>(
                label: 'Slika',
                flex: 1,
                cellBuilder: (s) => Align(
                  alignment: Alignment.centerLeft,
                  child: _SupplementImage(imageUrl: s.imageUrl),
                ),
              ),
              ColumnDef.text(
                label: 'Naziv',
                flex: 2,
                value: (s) => s.name,
                bold: true,
              ),
              ColumnDef.text(
                label: 'Cijena',
                flex: 1,
                value: (s) => '${s.price.toStringAsFixed(2)} KM',
              ),
              ColumnDef<SupplementResponse>(
                label: 'Stanje',
                flex: 1,
                cellBuilder: (s) => Text(
                  s.stockQuantity == 0
                      ? 'Nema'
                      : '${s.stockQuantity}',
                  style: TextStyle(
                    color: s.stockQuantity == 0
                        ? AppColors.error
                        : s.stockQuantity <= 5
                            ? AppColors.warning
                            : AppColors.textPrimary,
                    fontWeight: s.stockQuantity <= 5
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
              ColumnDef.text(
                label: 'Kategorija',
                flex: 2,
                value: (s) => s.supplementCategoryName ?? '-',
              ),
              ColumnDef.text(
                label: 'Dobavljac',
                flex: 2,
                value: (s) => s.supplierName ?? '-',
              ),
              ColumnDef.actions(
                flex: 2,
                builder: (s) => [
                  SmallButton(
                    text: 'Izmijeni',
                    color: AppColors.secondary,
                    onTap: () => _editSupplement(s),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SmallButton(
                    text: 'Obrisi',
                    color: AppColors.error,
                    onTap: () => _deleteSupplement(s),
                  ),
                ],
              ),
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
        );
  }
}

class _SupplementImage extends StatelessWidget {
  const _SupplementImage({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                ApiConfig.imageUrl(imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Icon(
                  LucideIcons.image,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            )
          : Icon(LucideIcons.image, color: AppColors.textMuted, size: 20),
    );
  }
}
