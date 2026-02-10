import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import 'gradient_button.dart';
import 'pagination_controls.dart';
import 'search_input.dart';
import 'shimmer_loading.dart';

/// Sort option for dropdown
class SortOption {
  final String? value;
  final String label;

  const SortOption({required this.value, required this.label});
}

/// Generic CRUD list scaffold with search, sort, pagination, and add button.
class CrudListScaffold<T, TFilter extends BaseQueryFilter>
    extends ConsumerStatefulWidget {
  const CrudListScaffold({
    super.key,
    required this.title,
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
  });

  final String title;
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

  @override
  ConsumerState<CrudListScaffold<T, TFilter>> createState() =>
      _CrudListScaffoldState<T, TFilter>();
}

class _CrudListScaffoldState<T, TFilter extends BaseQueryFilter>
    extends ConsumerState<CrudListScaffold<T, TFilter>> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchController.text = widget.state.filter.search ?? '';
    _selectedOrderBy = widget.state.filter.orderBy;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
          child: Container(
            padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceSolid,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title, style: AppTextStyles.headingMd),
                const SizedBox(height: AppSpacing.xxl),
                _buildSearchBar(constraints),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 600;
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: widget.searchHint,
          ),
          if (widget.sortOptions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildSortDropdown(),
          ],
          const SizedBox(height: AppSpacing.md),
          GradientButton(text: widget.addButtonText, onTap: widget.onAdd),
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
          const SizedBox(width: AppSpacing.lg),
          _buildSortDropdown(),
        ],
        const SizedBox(width: AppSpacing.lg),
        GradientButton(text: widget.addButtonText, onTap: widget.onAdd),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: Text('Sortiraj', style: AppTextStyles.bodyMd),
          dropdownColor: AppColors.surfaceSolid,
          style: AppTextStyles.bodyBold,
          icon: Icon(LucideIcons.arrowUpDown,
              color: AppColors.textMuted, size: 16),
          items: widget.sortOptions
              .map((opt) => DropdownMenuItem<String?>(
                    value: opt.value,
                    child: Text(opt.label),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedOrderBy = value);
            widget.onSort(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.state.isLoading) {
      return ShimmerTable(
        columnFlex: widget.loadingColumnFlex ?? const [2, 3, 2, 2],
      );
    }

    if (widget.state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
            const SizedBox(height: AppSpacing.sm),
            Text(widget.state.error!, style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(text: 'Pokusaj ponovo', onTap: widget.onRefresh),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPagination = constraints.maxHeight > 120;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: widget.tableBuilder(widget.state.items)),
            if (showPagination) ...[
              const SizedBox(height: AppSpacing.lg),
              PaginationControls(
                currentPage: widget.state.currentPage,
                totalPages: widget.state.totalPages,
                totalCount: widget.state.totalCount,
                onPageChanged: widget.onPageChanged,
              ),
            ],
          ],
        );
      },
    );
  }
}
