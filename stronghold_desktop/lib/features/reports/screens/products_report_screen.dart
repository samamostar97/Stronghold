import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/export_buttons.dart';

class ProductsReportScreen extends ConsumerWidget {
  const ProductsReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(productDateRangeProvider);
    final dataAsync = ref.watch(productsReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('Izvjestaji - Proizvodi', style: AppTextStyles.h2)),
              ReportDateRangePicker(
                from: range.from,
                to: range.to,
                onFromChanged: (d) => ref
                    .read(productDateRangeProvider.notifier)
                    .update(range.copyWith(from: d)),
                onToChanged: (d) => ref
                    .read(productDateRangeProvider.notifier)
                    .update(range.copyWith(to: d)),
              ),
              const SizedBox(width: 12),
              ExportButtons(
                endpoint: 'products',
                fileBaseName: 'proizvodi',
                dateRangeProvider: productDateRangeProvider,
              ),
            ],
          ),

          const SizedBox(height: 24),

          dataAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) =>
                _buildError(() => ref.invalidate(productsReportProvider)),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top selling
                Text('Najprodavaniji proizvodi', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildTopSellingTable(data.topSelling),

                const SizedBox(height: 32),

                // Stock levels
                Text('Stanje zaliha', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildStockTable(data.stockLevels),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingTable(List topSelling) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                _HeaderCell('PROIZVOD', flex: 3),
                _HeaderCell('KATEGORIJA', flex: 2),
                _HeaderCell('PRODANO', flex: 1),
                _HeaderCell('PRIHOD', flex: 1),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          if (topSelling.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text('Nema prodaje u odabranom periodu',
                    style: AppTextStyles.bodySmall),
              ),
            )
          else
            ...topSelling.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: i < 3
                                  ? AppColors.warning.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: i < 3
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(p.productName,
                                style:
                                    AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(p.categoryName,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${p.totalQuantitySold}',
                          style:
                              AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                          '${p.totalRevenue.toStringAsFixed(2)} KM',
                          style:
                              AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStockTable(List stockLevels) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                _HeaderCell('PROIZVOD', flex: 3),
                _HeaderCell('KATEGORIJA', flex: 2),
                _HeaderCell('ZALIHA', flex: 1),
                _HeaderCell('CIJENA', flex: 1),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          if (stockLevels.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text('Nema proizvoda', style: AppTextStyles.bodySmall),
              ),
            )
          else
            ...stockLevels.map((p) {
              final isLow = p.stockQuantity <= 5;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(p.productName,
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(p.categoryName,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLow
                              ? AppColors.error.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${p.stockQuantity}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isLow ? AppColors.error : null,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${p.price.toStringAsFixed(2)} KM',
                          style: AppTextStyles.body.copyWith(fontSize: 13)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildError(VoidCallback onRetry) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: TextButton(
          onPressed: onRetry,
          child: Text('Pokusaj ponovo',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  final int? flex;

  const _HeaderCell(this.label, {this.width, this.flex});

  @override
  Widget build(BuildContext context) {
    final child = Text(label, style: AppTextStyles.label.copyWith(fontSize: 11));
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }
}
