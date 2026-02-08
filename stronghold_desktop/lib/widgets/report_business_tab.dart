import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import 'bar_chart.dart';
import 'gradient_button.dart';
import 'report_export_button.dart';
import 'shimmer_loading.dart';
import 'stat_card.dart';

/// Business overview tab content for the report screen.
class ReportBusinessTab extends ConsumerWidget {
  const ReportBusinessTab({
    super.key,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.isExporting,
  });

  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final bool isExporting;

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
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.report,
    required this.onExportExcel,
    required this.onExportPdf,
  });

  final BusinessReportDTO report;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final statsCols = w < 600 ? 1 : (w < 900 ? 2 : 3);
      final chartsCols = w < 900 ? 1 : 2;
      final chartAspect = chartsCols == 1 ? (16 / 9) : (4 / 3);

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _exportRow(),
            const SizedBox(height: AppSpacing.xl),
            _statsGrid(statsCols),
            const SizedBox(height: AppSpacing.xxxl),
            _chartsGrid(chartsCols, chartAspect),
          ],
        ),
      );
    });
  }

  Widget _exportRow() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ReportExportButton.excel(onPressed: onExportExcel),
          const SizedBox(width: AppSpacing.md),
          ReportExportButton.pdf(onPressed: onExportPdf),
        ],
      );

  Widget _statsGrid(int cols) => LayoutBuilder(builder: (context, c) {
        const gap = 20.0;
        final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardW,
              child: StatCard(
                title: 'POSJETE OVE SEDMICE',
                value: '${report.thisWeekVisits}',
                trendValue:
                    '${report.weekChangePct.toStringAsFixed(1)}% vs prosle sedmice',
                isPositive: report.weekChangePct >= 0,
                accentColor: AppColors.primary,
              ),
            ),
            SizedBox(
              width: cardW,
              child: StatCard(
                title: 'PRODAJA OVOG MJESECA',
                value: '${report.thisMonthRevenue} KM',
                trendValue:
                    '${report.monthChangePct.toStringAsFixed(1)}% vs proslog mjeseca',
                isPositive: report.monthChangePct >= 0,
                accentColor: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardW,
              child: StatCard(
                title: 'AKTIVNIH CLANARINA',
                value: '${report.activeMemberships}',
                accentColor: AppColors.warning,
              ),
            ),
          ],
        );
      });

  Widget _chartsGrid(int cols, double chartAspect) =>
      LayoutBuilder(builder: (context, c) {
        const gap = 20.0;
        final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardW,
              child: _ChartCard(
                title: 'Sedmicna posjecenost po danima',
                child: AspectRatio(
                  aspectRatio: chartAspect,
                  child:
                      _WeekdayBarChart(visitsByWeekday: report.visitsByWeekday),
                ),
              ),
            ),
            SizedBox(
              width: cardW,
              child: _ChartCard(
                title: 'Bestseller suplement',
                child: _BestSeller(
                  name: report.bestsellerLast30Days?.name ?? 'N/A',
                  units: report.bestsellerLast30Days?.quantitySold ?? 0,
                ),
              ),
            ),
          ],
        );
      });
}

// ── Private helpers ─────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _WeekdayBarChart extends StatelessWidget {
  const _WeekdayBarChart({required this.visitsByWeekday});
  final List<WeekdayVisitsDTO> visitsByWeekday;

  static const _dayLabels = ['Pon', 'Uto', 'Sri', 'Cet', 'Pet', 'Sub', 'Ned'];
  static const _backendToDisplay = {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 0: 6};

  @override
  Widget build(BuildContext context) {
    final data = List.filled(7, 0);
    for (final entry in visitsByWeekday) {
      final idx = _backendToDisplay[entry.day];
      if (idx != null) data[idx] = entry.count;
    }
    return BarChart(
      items: [
        for (int i = 0; i < 7; i++)
          BarChartItem(
            label: _dayLabels[i],
            value: data[i].toDouble(),
            color: AppColors.accent,
          ),
      ],
      height: 200,
      barWidth: 28,
    );
  }
}

class _BestSeller extends StatelessWidget {
  const _BestSeller({required this.name, required this.units});
  final String name;
  final int units;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final narrow = c.maxWidth < 400;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: narrow
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [_icon(), const SizedBox(height: AppSpacing.lg), _info(true)],
              )
            : Row(children: [
                _icon(),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(child: _info(false)),
              ]),
      );
    });
  }

  Widget _icon() => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.pill, color: AppColors.accent, size: 56),
      );

  Widget _info(bool center) => Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name,
              style: AppTextStyles.headingMd,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: center ? TextAlign.center : TextAlign.left),
          const SizedBox(height: AppSpacing.xs),
          Text('Suplement',
              style: AppTextStyles.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment:
                center ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$units',
                  style: AppTextStyles.statLg.copyWith(color: AppColors.accent)),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('prodatih jedinica',
                      style: AppTextStyles.bodyMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('u posljednjih 30 dana',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.success)),
        ],
      );
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
        GradientButton(text: 'Pokusaj ponovo', onTap: onRetry),
      ]),
    );
  }
}
