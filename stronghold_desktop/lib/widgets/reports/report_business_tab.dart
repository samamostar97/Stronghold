import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/reports_provider.dart';
import '../dashboard/dashboard_revenue_summary.dart';
import '../dashboard/dashboard_sales_chart.dart';
import 'report_date_range_bar.dart';
import '../shared/shimmer_loading.dart';
import '../shared/stat_card.dart';

/// Revenue tab content for the report screen.
class ReportBusinessTab extends ConsumerWidget {
  const ReportBusinessTab({
    super.key,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.isExporting,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromChanged,
    required this.onDateToChanged,
  });

  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final bool isExporting;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(businessReportProvider);
    return async.when(
      loading: () => const ShimmerDashboard(),
      error: (error, _) => _ErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(businessReportProvider),
      ),
      data: (report) => _Body(
        report: report,
        onExportExcel: isExporting ? null : onExportExcel,
        onExportPdf: isExporting ? null : onExportPdf,
        dateFrom: dateFrom,
        dateTo: dateTo,
        onDateFromChanged: onDateFromChanged,
        onDateToChanged: onDateToChanged,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.report,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromChanged,
    required this.onDateToChanged,
  });

  final BusinessReportDTO report;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<DateTime?> onDateFromChanged;
  final ValueChanged<DateTime?> onDateToChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final statsCols = w < 600 ? 1 : (w < 900 ? 2 : 3);
      final bottomCols = w < 900 ? 1 : 2;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _exportRow(),
            const SizedBox(height: AppSpacing.xl),
            _statsGrid(statsCols, w),
            const SizedBox(height: AppSpacing.xxl),
            const DashboardSalesChart(),
            const SizedBox(height: AppSpacing.xxl),
            _bottomSection(bottomCols, w),
          ],
        ),
      );
    });
  }

  Widget _exportRow() => ReportDateRangeBar(
        dateFrom: dateFrom,
        dateTo: dateTo,
        onDateFromChanged: onDateFromChanged,
        onDateToChanged: onDateToChanged,
        onExportExcel: onExportExcel,
        onExportPdf: onExportPdf,
      );

  Widget _statsGrid(int cols, double maxWidth) {
    const gap = 20.0;
    final cardW = (maxWidth - gap * (cols - 1)) / cols;
    final rb = report.revenueBreakdown;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        SizedBox(
          width: cardW,
          child: StatCard(
            title: 'PRODAJA OVOG MJESECA',
            value: '${report.thisMonthRevenue.toStringAsFixed(2)} KM',
            trendValue:
                '${report.monthChangePct.toStringAsFixed(1)}% vs proslog mjeseca',
            isPositive: report.monthChangePct >= 0,
            accentColor: AppColors.success,
          ),
        ),
        SizedBox(
          width: cardW,
          child: StatCard(
            title: 'PRODAJA DANAS',
            value: '${rb?.todayRevenue.toStringAsFixed(2) ?? '0.00'} KM',
            trendValue: '${rb?.todayOrderCount ?? 0} narudzbi danas',
            isPositive: (rb?.todayOrderCount ?? 0) > 0,
            accentColor: AppColors.primary,
          ),
        ),
        SizedBox(
          width: cardW,
          child: StatCard(
            title: 'PROSJECNA NARUDZBA',
            value: '${rb?.averageOrderValue.toStringAsFixed(2) ?? '0.00'} KM',
            trendValue: 'Prosjek zadnjih 30 dana',
            accentColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _bottomSection(int cols, double maxWidth) {
    final rightColumn = Column(
      children: [
        _BestSellerCard(bestseller: report.bestsellerLast30Days),
        const SizedBox(height: AppSpacing.lg),
        _SlowestMovingCard(product: report.slowestMovingLast30Days),
      ],
    );

    if (cols == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardRevenueSummary(breakdown: report.revenueBreakdown),
          const SizedBox(height: AppSpacing.xxl),
          rightColumn,
        ],
      );
    }

    const gap = 20.0;
    final cardW = (maxWidth - gap) / 2;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: cardW,
            child: DashboardRevenueSummary(breakdown: report.revenueBreakdown),
          ),
          const SizedBox(width: gap),
          SizedBox(
            width: cardW,
            child: rightColumn,
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────────────────

class _BestSellerCard extends StatelessWidget {
  const _BestSellerCard({required this.bestseller});
  final BestSellerDTO? bestseller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trendingUp, size: 16, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Bestseller (30d)', style: AppTextStyles.headingSm),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (bestseller == null)
            Center(child: Text('Nema podataka', style: AppTextStyles.bodyMd))
          else
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.pill, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bestseller!.name,
                          style: AppTextStyles.bodyBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${bestseller!.quantitySold} prodatih',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SlowestMovingCard extends StatelessWidget {
  const _SlowestMovingCard({required this.product});
  final SlowestMovingDTO? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trendingDown, size: 16, color: AppColors.orange),
              const SizedBox(width: AppSpacing.sm),
              Text('Najsporiji (30d)', style: AppTextStyles.headingSm),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (product == null)
            Center(child: Text('Nema podataka', style: AppTextStyles.bodyMd))
          else
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.pill, color: AppColors.orange, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product!.name,
                          style: AppTextStyles.bodyBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${product!.quantitySold} prodatih, ${product!.daysSinceLastSale}d od zadnje',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.alertCircle, color: AppColors.error, size: 48),
        const SizedBox(height: AppSpacing.lg),
        Text(message,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        GradientButton.text(text: 'Pokusaj ponovo', onPressed: onRetry),
      ]),
    );
  }
}
