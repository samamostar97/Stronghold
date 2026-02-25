import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../providers/list_state.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/reports_provider.dart';
import '../../utils/debouncer.dart';
import '../shared/bar_chart.dart';
import '../shared/data_table_widgets.dart';
import '../shared/horizontal_bar_chart.dart';
import '../shared/pagination_controls.dart';
import 'report_export_button.dart';
import '../shared/search_input.dart';

/// Inventory tab content for the report screen.
class ReportInventoryTab extends ConsumerStatefulWidget {
  const ReportInventoryTab({
    super.key,
    required this.daysToAnalyze,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.isExporting,
  });

  final int daysToAnalyze;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final bool isExporting;

  @override
  ConsumerState<ReportInventoryTab> createState() => _ReportInventoryTabState();
}

class _ReportInventoryTabState extends ConsumerState<ReportInventoryTab> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    final initialSearch =
        ref.read(slowMovingProductsProvider).filter.search ?? '';
    _searchController.text = initialSearch;
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(slowMovingProductsProvider.notifier)
          .setDaysToAnalyze(widget.daysToAnalyze);
    });
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
      final q = _searchController.text.trim();
      ref
          .read(slowMovingProductsProvider.notifier)
          .setSearch(q.isEmpty ? '' : q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      inventorySummaryProvider(widget.daysToAnalyze),
    );
    final reportAsync = ref.watch(
      inventoryReportProvider(widget.daysToAnalyze),
    );
    final productsState = ref.watch(slowMovingProductsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _exportRow(),
          const SizedBox(height: AppSpacing.xl),
          _summaryCards(summaryAsync),
          const SizedBox(height: AppSpacing.xxl),
          _chartsSection(reportAsync),
          const SizedBox(height: AppSpacing.xxl),
          _productsSection(productsState),
        ],
      ),
    );
  }

  Widget _exportRow() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      ReportExportButton.excel(
        onPressed: widget.isExporting ? null : widget.onExportExcel,
      ),
      const SizedBox(width: AppSpacing.md),
      ReportExportButton.pdf(
        onPressed: widget.isExporting ? null : widget.onExportPdf,
      ),
    ],
  );

  Widget _summaryCards(AsyncValue<InventorySummaryDTO> async) => async.when(
    loading: () => const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    ),
    error: (e, _) => Text(
      'Greska: ${e.toString().replaceFirst('Exception: ', '')}',
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
    ),
    data: (s) => Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.package,
            label: 'Ukupno proizvoda',
            value: '${s.totalProducts}',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.alertTriangle,
            label: 'Slaba prodaja',
            value: '${s.slowMovingCount}',
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.calendar,
            label: 'Period analize',
            value: '${s.daysAnalyzed} dana',
            color: AppColors.secondary,
          ),
        ),
      ],
    ),
  );

  Widget _chartsSection(AsyncValue<InventoryReportDTO> async) => async.when(
    loading: () => const SizedBox(
      height: 240,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    ),
    error: (error, stackTrace) => const SizedBox.shrink(),
    data: (report) {
      final products = report.slowMovingProducts;
      if (products.isEmpty) return const SizedBox.shrink();

      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;

          final categoryGroups = <String, int>{};
          for (final p in products) {
            categoryGroups[p.categoryName] =
                (categoryGroups[p.categoryName] ?? 0) + 1;
          }
          final categoryColors = [
            AppColors.accent,
            AppColors.orange,
            AppColors.primary,
            AppColors.secondary,
            AppColors.error,
            AppColors.warning,
            AppColors.success,
          ];
          final categoryItems = categoryGroups.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final barItems = categoryItems
              .map(
                (e) => BarChartItem(
                  label: e.key.length > 12
                      ? '${e.key.substring(0, 10)}..'
                      : e.key,
                  value: e.value.toDouble(),
                  color:
                      categoryColors[categoryItems.indexOf(e) %
                          categoryColors.length],
                ),
              )
              .toList();

          final sorted = products.toList()
            ..sort(
              (a, b) => b.daysSinceLastSale.compareTo(a.daysSinceLastSale),
            );
          final topData = sorted
              .take(8)
              .map(
                (p) => (
                  label: p.name.length > 14
                      ? '${p.name.substring(0, 12)}..'
                      : p.name,
                  value: p.daysSinceLastSale.toDouble(),
                ),
              )
              .toList();

          final categoryChart = _ChartCard(
            icon: LucideIcons.pieChart,
            title: 'Po kategorijama',
            child: barItems.isEmpty
                ? Center(
                    child: Text('Nema podataka', style: AppTextStyles.bodyMd),
                  )
                : BarChart(
                    items: barItems,
                    height: 200,
                    barWidth: barItems.length > 6 ? 18 : 24,
                  ),
          );

          final slowMoversChart = _ChartCard(
            icon: LucideIcons.clock,
            title: 'Najduze bez prodaje',
            child: topData.isEmpty
                ? Center(
                    child: Text('Nema podataka', style: AppTextStyles.bodyMd),
                  )
                : HorizontalBarChart(
                    data: topData,
                    accentColor: AppColors.orange,
                  ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: categoryChart),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: slowMoversChart),
              ],
            );
          }

          return Column(
            children: [
              categoryChart,
              const SizedBox(height: AppSpacing.lg),
              slowMoversChart,
            ],
          );
        },
      );
    },
  );

  Widget _productsSection(
    ListState<SlowMovingProductDTO, SlowMovingProductQueryFilter> state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Icon(
                  LucideIcons.trendingDown,
                  color: AppColors.orange,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Proizvodi sa slabom prodajom (<=2 prodaje)',
                    style: AppTextStyles.headingSm,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _filtersBar(constraints, state),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    state.error!.replaceFirst('Exception: ', ''),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GradientButton.text(
                    text: 'Pokusaj ponovo',
                    onPressed: () =>
                        ref.read(slowMovingProductsProvider.notifier).refresh(),
                  ),
                ],
              ),
            )
          else if (state.isEmpty && !state.isLoading)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      color: AppColors.success,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Svi proizvodi imaju dobru prodaju!',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _InventoryTable(products: state.items),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PaginationControls(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                totalCount: state.totalCount,
                onPageChanged: (p) =>
                    ref.read(slowMovingProductsProvider.notifier).goToPage(p),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filtersBar(
    BoxConstraints constraints,
    ListState<SlowMovingProductDTO, SlowMovingProductQueryFilter> state,
  ) {
    final notifier = ref.read(slowMovingProductsProvider.notifier);
    final sortDropdown = _sortDropdown(state, notifier);

    if (constraints.maxWidth < 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (value) {
              final q = value.trim();
              notifier.setSearch(q.isEmpty ? '' : q);
            },
            hintText: 'Pretrazi proizvode i kategorije...',
          ),
          const SizedBox(height: AppSpacing.md),
          sortDropdown,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: _searchController,
            onSubmitted: (value) {
              final q = value.trim();
              notifier.setSearch(q.isEmpty ? '' : q);
            },
            hintText: 'Pretrazi proizvode i kategorije...',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        sortDropdown,
      ],
    );
  }

  Widget _sortDropdown(
    ListState<SlowMovingProductDTO, SlowMovingProductQueryFilter> state,
    SlowMovingProductsNotifier notifier,
  ) {
    final selectedOrderBy = state.filter.orderBy;
    final dropdownValue = selectedOrderBy == null || selectedOrderBy.isEmpty
        ? null
        : selectedOrderBy;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: dropdownValue,
          hint: Text('Sortiraj', style: AppTextStyles.bodyMd),
          dropdownColor: AppColors.surfaceSolid,
          style: AppTextStyles.bodyBold,
          icon: Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 16,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(
              value: 'quantitysold',
              child: Text('Najmanje prodato'),
            ),
            DropdownMenuItem(
              value: 'quantitysolddesc',
              child: Text('Najvise prodato'),
            ),
            DropdownMenuItem(
              value: 'dayssincelastsaledesc',
              child: Text('Najduze bez prodaje'),
            ),
            DropdownMenuItem(
              value: 'dayssincelastsale',
              child: Text('Najkrace bez prodaje'),
            ),
            DropdownMenuItem(value: 'name', child: Text('Naziv (A-Z)')),
            DropdownMenuItem(value: 'namedesc', child: Text('Naziv (Z-A)')),
            DropdownMenuItem(
              value: 'category',
              child: Text('Kategorija (A-Z)'),
            ),
            DropdownMenuItem(
              value: 'categorydesc',
              child: Text('Kategorija (Z-A)'),
            ),
            DropdownMenuItem(value: 'price', child: Text('Cijena (niza)')),
            DropdownMenuItem(value: 'pricedesc', child: Text('Cijena (visa)')),
          ],
          onChanged: (value) => notifier.setOrderBy(value),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySm),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.stat.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.headingSm),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.products});
  final List<SlowMovingProductDTO> products;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            children: [
              TableHeader(
                child: Row(
                  children: [
                    TableHeaderCell(text: 'Naziv', flex: 3),
                    TableHeaderCell(text: 'Kategorija', flex: 2),
                    TableHeaderCell(text: 'Cijena', flex: 2),
                    TableHeaderCell(text: 'Prodato', flex: 1),
                    TableHeaderCell(
                      text: 'Dana bez prodaje',
                      flex: 2,
                      alignRight: true,
                    ),
                  ],
                ),
              ),
              ...products.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                final isLast = i == products.length - 1;
                return HoverableTableRow(
                  index: i,
                  isLast: isLast,
                  child: Row(
                    children: [
                      TableDataCell(text: p.name, flex: 3, bold: true),
                      TableDataCell(text: p.categoryName, flex: 2, muted: true),
                      TableDataCell(
                        text: '${p.price.toStringAsFixed(2)} KM',
                        flex: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: _soldBadge(p.quantitySold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${p.daysSinceLastSale}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyBold.copyWith(
                            color: _daysColor(p.daysSinceLastSale),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soldBadge(int qty) {
    final color = qty == 0 ? AppColors.error : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text('$qty', style: AppTextStyles.badge.copyWith(color: color)),
    );
  }

  Color _daysColor(int days) {
    if (days > 20) return AppColors.error;
    if (days > 10) return AppColors.orange;
    return AppColors.textMuted;
  }
}
