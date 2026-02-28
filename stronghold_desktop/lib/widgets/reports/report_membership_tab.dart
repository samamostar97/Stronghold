import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/reports_provider.dart';
import 'report_date_range_bar.dart';
import 'visits_trend_chart.dart';
import '../shared/shimmer_loading.dart';

/// Visits (Posjete) tab content for the report screen.
class ReportVisitsTab extends ConsumerWidget {
  const ReportVisitsTab({
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _exportRow(),
          const SizedBox(height: AppSpacing.xl),
          _summaryCards(),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 300,
            child: VisitsTrendChart(data: report.dailyVisits),
          ),
          const SizedBox(height: AppSpacing.xl),
          _DailyVisitsBarChart(data: report.dailyVisits),
          const SizedBox(height: AppSpacing.xl),
          _bottomRow(),
        ],
      ),
    );
  }

  Widget _exportRow() => ReportDateRangeBar(
        onExportExcel: onExportExcel,
        onExportPdf: onExportPdf,
      );

  Widget _bottomRow() => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ActivePackageCard(data: report.mostActivePackage),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _GrowthRateCard(growthRate: report.growthRate),
            ),
          ],
        ),
      );

  Widget _summaryCards() => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SummaryCard(
                icon: LucideIcons.footprints,
                label: 'Posjete u ovom mjesecu',
                value: '${report.thisMonthVisits}',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BusiestDayCard(busiestDay: report.busiestDay),
            ),
          ],
        ),
      );
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

class _BusiestDayCard extends StatelessWidget {
  const _BusiestDayCard({required this.busiestDay});

  final BusiestDayDTO? busiestDay;

  @override
  Widget build(BuildContext context) {
    const title = 'Najprometniji dan ovaj mjesec';

    String? dateStr;
    String description;
    if (busiestDay != null) {
      final d = busiestDay!.date;
      dateStr = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
      description = 'Taj dan je bilo ${busiestDay!.visitCount} posjeta';
    } else {
      description = 'Nema podataka';
    }

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
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(LucideIcons.calendarCheck, color: AppColors.success, size: 24),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              if (dateStr != null)
                Text(
                  dateStr,
                  style: AppTextStyles.stat.copyWith(color: AppColors.success),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(description, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _ActivePackageCard extends StatelessWidget {
  const _ActivePackageCard({required this.data});

  final MostActivePackageDTO? data;

  @override
  Widget build(BuildContext context) {
    const title = 'Najaktivniji paket u ovom mjesecu';

    final packageName = data?.packageName ?? 'Nema podataka';
    final visitCount = data?.visitCount ?? 0;

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
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(LucideIcons.award, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              Text(
                packageName,
                style: AppTextStyles.stat.copyWith(color: AppColors.primary),
                overflow: TextOverflow.ellipsis,
              ),
              if (data != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ukupno $visitCount posjeta',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

class _GrowthRateCard extends StatelessWidget {
  const _GrowthRateCard({required this.growthRate});

  final GrowthRateDTO? growthRate;

  @override
  Widget build(BuildContext context) {
    final pct = growthRate?.growthPct.toDouble() ?? 0;
    final isPositive = pct >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown;
    final sign = isPositive ? '+' : '';
    const description = 'Zadnjih 30 dana';

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
              Text('Stopa rasta', style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$sign${pct.toStringAsFixed(1)}%',
                style: AppTextStyles.stat.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DailyVisitsBarChart extends StatefulWidget {
  const _DailyVisitsBarChart({required this.data});
  final List<DailyVisitsDTO> data;

  @override
  State<_DailyVisitsBarChart> createState() => _DailyVisitsBarChartState();
}

class _DailyVisitsBarChartState extends State<_DailyVisitsBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;
  late List<DailyVisitsDTO> _sorted;
  late double _maxVal;

  @override
  void initState() {
    super.initState();
    _computeData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(_DailyVisitsBarChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _computeData();
      _controller.forward(from: 0);
    }
  }

  void _computeData() {
    _sorted = widget.data.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _maxVal = _sorted.isEmpty
        ? 0
        : _sorted.map((d) => d.visitCount).reduce((a, b) => a > b ? a : b).toDouble();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    if (sorted.isEmpty) return const SizedBox.shrink();

    final maxVal = _maxVal;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Posjete po danima', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Zadnjih 30 dana',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = Curves.easeOutCubic.transform(_controller.value);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final barCount = sorted.length;
                    final gap = 2.0;
                    final barWidth = (constraints.maxWidth - gap * (barCount - 1)) / barCount;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(barCount, (i) {
                        final item = sorted[i];
                        final fraction = maxVal > 0 ? item.visitCount / maxVal : 0.0;
                        final barHeight = fraction * 150 * progress;
                        final isHovered = _hoveredIndex == i;
                        final isPeak = item.visitCount == maxVal.toInt() && maxVal > 0;

                        return Padding(
                          padding: EdgeInsets.only(right: i < barCount - 1 ? gap : 0),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = i),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: Tooltip(
                              message: '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}. — ${item.visitCount} posjeta',
                              waitDuration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: barWidth,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: barWidth,
                                      height: barHeight.clamp(0.0, 150.0),
                                      decoration: BoxDecoration(
                                        gradient: isPeak || isHovered
                                            ? const LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [AppColors.accent, AppColors.cyan],
                                              )
                                            : null,
                                        color: isPeak || isHovered ? null : AppColors.accent.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(barWidth > 6 ? 4 : 2),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 26,
                                      child: i % 5 == 0 || i == barCount - 1
                                          ? FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '${item.date.day}.${item.date.month}',
                                                style: AppTextStyles.overline.copyWith(
                                                  fontSize: 9,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                );
              },
            ),
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
