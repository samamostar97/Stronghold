import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import 'gradient_button.dart';
import 'pagination_controls.dart';
import 'search_input.dart';

/// Sort option for dropdown
class SortOption {
  final String? value;
  final String label;

  const SortOption({required this.value, required this.label});
}

/// Generic CRUD list scaffold with search, sort, pagination, and add button.
/// Reduces ~400 lines of boilerplate per screen to ~50 lines.
class CrudListScaffold<T, TFilter extends BaseQueryFilter> extends ConsumerStatefulWidget {
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
    this.searchHint = 'Pretraži...',
    this.addButtonText = '+ Dodaj',
    this.sortOptions = const [],
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

  @override
  ConsumerState<CrudListScaffold<T, TFilter>> createState() => _CrudListScaffoldState<T, TFilter>();
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
    // Initialize from filter state
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
      // Pass empty string (not null) when cleared - null means "keep old value" in createFilterCopy
      final text = _searchController.text.trim();
      widget.onSearch(text.isEmpty ? '' : text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 1200
            ? 40.0
            : constraints.maxWidth > 800
                ? 24.0
                : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Container(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 28 : 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSearchBar(constraints),
                const SizedBox(height: 24),
                Expanded(child: _buildContent(constraints)),
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
            const SizedBox(height: 12),
            _buildSortDropdown(),
          ],
          const SizedBox(height: 12),
          GradientButton(
            text: widget.addButtonText,
            onTap: widget.onAdd,
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
          const SizedBox(width: 16),
          _buildSortDropdown(),
        ],
        const SizedBox(width: 16),
        GradientButton(
          text: widget.addButtonText,
          onTap: widget.onAdd,
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: const Text(
            'Sortiraj',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          dropdownColor: AppColors.panel,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.sort, color: AppColors.muted, size: 20),
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

  Widget _buildContent(BoxConstraints constraints) {
    if (widget.state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (widget.state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greška pri učitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.state.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokušaj ponovo', onTap: widget.onRefresh),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: widget.tableBuilder(widget.state.items)),
        const SizedBox(height: 16),
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
