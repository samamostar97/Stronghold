import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/list_state.dart';
import '../../utils/debouncer.dart';
import 'pagination_controls.dart';
import 'search_input.dart';
import 'shimmer_loading.dart';
import 'small_button.dart';

class SortOption {
  const SortOption({required this.value, required this.label});

  final String? value;
  final String label;
}

class CrudListScaffold<T, TFilter extends BaseQueryFilter>
    extends ConsumerStatefulWidget {
  const CrudListScaffold({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onSearch,
    required this.onSort,
    required this.onPageChanged,
    required this.onAdd,
    required this.tableBuilder,
    this.searchHint = 'Pretrazi...',
    this.addButtonText = '+ Dodaj',
    this.sortOptions = const [],
    this.loadingColumnFlex,
    this.extraFilter,
    this.embedded = false,
  });

  final ListState<T, TFilter> state;
  final VoidCallback onRefresh;
  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onSort;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onAdd;
  final Widget Function(List<T> items) tableBuilder;
  final String searchHint;
  final String addButtonText;
  final List<SortOption> sortOptions;
  final List<int>? loadingColumnFlex;
  final Widget? extraFilter;
  final bool embedded;

  @override
  ConsumerState<CrudListScaffold<T, TFilter>> createState() =>
      _CrudListScaffoldState<T, TFilter>();
}

class _CrudListScaffoldState<T, TFilter extends BaseQueryFilter>
    extends ConsumerState<CrudListScaffold<T, TFilter>> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchController.text = widget.state.filter.search ?? '';
    final order = widget.state.filter.orderBy;
    _selectedOrderBy = (order == null || order.isEmpty) ? null : order;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      final text = _searchController.text.trim();
      widget.onSearch(text.isEmpty ? '' : text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _toolbar(),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: _content()),
      ],
    );

    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: content,
      );
    }

    return Padding(
      padding: AppSpacing.desktopPage,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: content,
      ),
    );
  }

  Widget _toolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 860;

        final sortDropdown = widget.sortOptions.isEmpty
            ? const SizedBox.shrink()
            : _buildSortDropdown();

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchInput(
                controller: _searchController,
                onSubmitted: (_) {},
                hintText: widget.searchHint,
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.sortOptions.isNotEmpty) ...[
                sortDropdown,
                const SizedBox(height: AppSpacing.md),
              ],
              if (widget.extraFilter != null) ...[
                widget.extraFilter!,
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                children: [
                  SmallButton(
                    text: 'Osvjezi',
                    color: AppColors.secondary,
                    onTap: widget.onRefresh,
                  ),
                  const SizedBox(width: 8),
                  SmallButton(
                    text: widget.addButtonText,
                    color: AppColors.primary,
                    onTap: widget.onAdd,
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SearchInput(
                controller: _searchController,
                onSubmitted: (_) {},
                hintText: widget.searchHint,
              ),
            ),
            if (widget.sortOptions.isNotEmpty) ...[
              const SizedBox(width: 10),
              sortDropdown,
            ],
            if (widget.extraFilter != null) ...[
              const SizedBox(width: 10),
              widget.extraFilter!,
            ],
            const SizedBox(width: 10),
            SmallButton(
              text: 'Osvjezi',
              color: AppColors.secondary,
              onTap: widget.onRefresh,
            ),
            const SizedBox(width: 8),
            SmallButton(
              text: widget.addButtonText,
              color: AppColors.primary,
              onTap: widget.onAdd,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: Text('Sort', style: AppTextStyles.bodySecondary),
          icon: const Icon(
            LucideIcons.arrowUpDown,
            size: 15,
            color: AppColors.textMuted,
          ),
          items: widget.sortOptions
              .map(
                (opt) => DropdownMenuItem<String?>(
                  value: opt.value,
                  child: Text(opt.label, style: AppTextStyles.bodySecondary),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedOrderBy = value);
            widget.onSort(value);
          },
        ),
      ),
    );
  }

  Widget _content() {
    if (widget.state.isLoading) {
      return ShimmerTable(
        columnFlex: widget.loadingColumnFlex ?? const [3, 3, 2, 2],
      );
    }

    if (widget.state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              widget.state.error!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SmallButton(
              text: 'Pokusaj ponovo',
              color: AppColors.primary,
              onTap: widget.onRefresh,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: widget.tableBuilder(widget.state.items)),
        const SizedBox(height: AppSpacing.md),
        PaginationControls(
          currentPage: widget.state.currentPage,
          totalPages: widget.state.totalPages,
          totalCount: widget.state.totalCount,
          onPageChanged: widget.onPageChanged,
        ),
      ],
    );
  }
}
