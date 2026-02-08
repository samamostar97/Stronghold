import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../providers/list_state.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import 'data_table_widgets.dart';
import 'gradient_button.dart';
import 'pagination_controls.dart';
import 'report_export_button.dart';

/// Inventory tab content for the report screen.
class ReportInventoryTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(inventorySummaryProvider(daysToAnalyze));
    final productsState = ref.watch(slowMovingProductsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _exportRow(),
          const SizedBox(height: AppSpacing.xl),
          _summaryCards(summaryAsync),
          const SizedBox(height: AppSpacing.xxl),
          _productsSection(ref, productsState),
        ],
      ),
    );
  }

  Widget _exportRow() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ReportExportButton.excel(
              onPressed: isExporting ? null : onExportExcel),
          const SizedBox(width: AppSpacing.md),
          ReportExportButton.pdf(onPressed: isExporting ? null : onExportPdf),
        ],
      );

  Widget _summaryCards(AsyncValue<InventorySummaryDTO> async) => async.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (e, _) => Text(
          'Greska: ${e.toString().replaceFirst('Exception: ', '')}',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
        ),
        data: (s) => Row(children: [
          Expanded(child: _SummaryCard(
            icon: LucideIcons.package,
            label: 'Ukupno proizvoda',
            value: '${s.totalProducts}',
            color: AppColors.accent,
          )),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: _SummaryCard(
            icon: LucideIcons.alertTriangle,
            label: 'Slaba prodaja',
            value: '${s.slowMovingCount}',
            color: AppColors.orange,
          )),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: _SummaryCard(
            icon: LucideIcons.calendar,
            label: 'Period analize',
            value: '${s.daysAnalyzed} dana',
            color: AppColors.secondary,
          )),
        ]),
      );

  Widget _productsSection(
    WidgetRef ref,
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
            child: Row(children: [
              Icon(LucideIcons.trendingDown,
                  color: AppColors.orange, size: 24),
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
                      strokeWidth: 2, color: AppColors.primary),
                ),
            ]),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(children: [
                Text(
                  state.error!.replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.md),
                GradientButton(
                  text: 'Pokusaj ponovo',
                  onTap: () => ref
                      .read(slowMovingProductsProvider.notifier)
                      .refresh(),
                ),
              ]),
            )
          else if (state.isEmpty && !state.isLoading)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.checkCircle,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text('Svi proizvodi imaju dobru prodaju!',
                      style: AppTextStyles.bodyMd),
                ]),
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
                onPageChanged: (p) => ref
                    .read(slowMovingProductsProvider.notifier)
                    .goToPage(p),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────────────────

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
      child: Row(children: [
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
              Text(value,
                  style: AppTextStyles.stat.copyWith(color: color),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
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
          child: Column(children: [
            TableHeader(
              child: Row(children: [
                TableHeaderCell(text: 'Naziv', flex: 3),
                TableHeaderCell(text: 'Kategorija', flex: 2),
                TableHeaderCell(text: 'Cijena', flex: 2),
                TableHeaderCell(text: 'Prodato', flex: 1),
                TableHeaderCell(text: 'Dana bez prodaje', flex: 2, alignRight: true),
              ]),
            ),
            ...products.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              final isLast = i == products.length - 1;
              return HoverableTableRow(
                index: i,
                isLast: isLast,
                child: Row(children: [
                  TableDataCell(text: p.name, flex: 3, bold: true),
                  TableDataCell(text: p.categoryName, flex: 2, muted: true),
                  TableDataCell(
                      text: '${p.price.toStringAsFixed(2)} KM', flex: 2),
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
                          color: _daysColor(p.daysSinceLastSale)),
                    ),
                  ),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _soldBadge(int qty) {
    final color = qty == 0 ? AppColors.error : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text('$qty',
          style: AppTextStyles.badge.copyWith(color: color)),
    );
  }

  Color _daysColor(int days) {
    if (days > 20) return AppColors.error;
    if (days > 10) return AppColors.orange;
    return AppColors.textMuted;
  }
}
