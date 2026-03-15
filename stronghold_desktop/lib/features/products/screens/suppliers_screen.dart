import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/supplier_response.dart';
import '../providers/products_provider.dart';
import '../widgets/supplier_form_modal.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(suppliersFilterProvider.notifier).update(SuppliersFilter(
        search: value.isEmpty ? null : value,
      ));
    });
  }

  void _openCreateModal() {
    showDialog(
      context: context,
      builder: (_) => const SupplierFormModal(),
    );
  }

  void _openEditModal(SupplierResponse supplier) {
    showDialog(
      context: context,
      builder: (_) => SupplierFormModal(supplier: supplier),
    );
  }

  void _confirmDelete(SupplierResponse supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Obrisi dobavljaca', style: AppTextStyles.h3),
        content: Text(
          'Da li ste sigurni da zelite obrisati "${supplier.name}"?',
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
                final repo = ref.read(suppliersRepositoryProvider);
                await repo.deleteSupplier(supplier.id);
                ref.invalidate(suppliersListProvider);
                if (mounted) {
                  AppSnackbar.success(context, '"${supplier.name}" je obrisan.');
                }
              } catch (e) {
                if (mounted) {
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
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    final filter = ref.watch(suppliersFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Dobavljaci', style: AppTextStyles.h2)),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _openCreateModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Dodaj dobavljaca',
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
              const SizedBox(width: 12),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi dobavljace...',
                    hintStyle:
                        AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppColors.sidebar,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color:
                              AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          suppliersAsync.when(
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
                    Text('Greska pri ucitavanju dobavljaca',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(suppliersListProvider),
                      child: Text('Pokusaj ponovo',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) => _SuppliersTable(
              suppliers: data.items,
              currentPage: data.currentPage,
              totalPages: data.totalPages,
              onPageChanged: (page) {
                ref.read(suppliersFilterProvider.notifier).update(
                    filter.copyWith(pageNumber: page));
              },
              onEdit: _openEditModal,
              onDelete: _confirmDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuppliersTable extends StatefulWidget {
  final List<SupplierResponse> suppliers;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<SupplierResponse>? onEdit;
  final ValueChanged<SupplierResponse>? onDelete;

  const _SuppliersTable({
    required this.suppliers,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_SuppliersTable> createState() => _SuppliersTableState();
}

class _SuppliersTableState extends State<_SuppliersTable> {
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                        width: 50,
                        child: Text('ID',
                            style:
                                AppTextStyles.label.copyWith(fontSize: 11))),
                    Expanded(
                        flex: 2,
                        child: Text('Naziv',
                            style:
                                AppTextStyles.label.copyWith(fontSize: 11))),
                    Expanded(
                        flex: 2,
                        child: Text('Email',
                            style:
                                AppTextStyles.label.copyWith(fontSize: 11))),
                    Expanded(
                        flex: 1,
                        child: Text('Telefon',
                            style:
                                AppTextStyles.label.copyWith(fontSize: 11))),
                    Expanded(
                        flex: 2,
                        child: Text('Website',
                            style:
                                AppTextStyles.label.copyWith(fontSize: 11))),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              if (widget.suppliers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Nema dobavljaca',
                        style: AppTextStyles.bodySmall),
                  ),
                )
              else
                ...widget.suppliers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final supplier = entry.value;
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
                              '#${supplier.id}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13, color: AppColors.primary),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              supplier.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              supplier.email ?? '-',
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              supplier.phone ?? '-',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              supplier.website ?? '-',
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 13),
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
                                      widget.onEdit?.call(supplier),
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
                                      widget.onDelete?.call(supplier),
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
        ),

        // Pagination
        if (widget.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.currentPage > 1
                      ? () =>
                          widget.onPageChanged(widget.currentPage - 1)
                      : null,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: widget.currentPage > 1
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(widget.totalPages, (i) {
                  final page = i + 1;
                  final isActive = page == widget.currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () => widget.onPageChanged(page),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$page',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.currentPage < widget.totalPages
                      ? () =>
                          widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.currentPage < widget.totalPages
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
