import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/reports_provider.dart';
import '../shared/ring_chart.dart';
import '../shared/shimmer_loading.dart';
import '../shared/stat_card.dart';
import 'report_date_range_bar.dart';

/// Staff (Osoblje) tab content for the report screen.
class ReportStaffTab extends ConsumerWidget {
  const ReportStaffTab({
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
    final async = ref.watch(staffReportProvider);

    return async.when(
      loading: () => const ShimmerDashboard(),
      error: (e, _) => _ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(staffReportProvider),
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

  final StaffReportDTO report;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 900;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportDateRangeBar(
              onExportExcel: onExportExcel,
              onExportPdf: onExportPdf,
            ),
            const SizedBox(height: AppSpacing.xl),
            _kpiCards(wide),
            const SizedBox(height: AppSpacing.xxl),
            _chartsRow(wide),
          ],
        ),
      );
    });
  }

  Widget _kpiCards(bool wide) {
    final trainers = report.staffRanking.where((r) => r.type == 'Trener').toList();
    final nutritionists = report.staffRanking.where((r) => r.type == 'Nutricionista').toList();

    final topTrainer = trainers.firstOrNull;
    final topNutritionist = nutritionists.firstOrNull;

    final activeTrainerIds = trainers.length;
    final activeNutritionistIds = nutritionists.length;
    final inactive = (report.totalTrainers - activeTrainerIds) +
        (report.totalNutritionists - activeNutritionistIds);

    final cards = [
      StatCard(
        title: 'NAJTRAZENIJI TRENER',
        value: topTrainer?.name ?? 'Nema podataka',
        trendValue: topTrainer != null ? '${topTrainer.appointmentCount} termina' : null,
        isPositive: true,
        accentColor: AppColors.cyan,
      ),
      StatCard(
        title: 'NAJTRAZENIJI NUTRICIONIST',
        value: topNutritionist?.name ?? 'Nema podataka',
        trendValue: topNutritionist != null ? '${topNutritionist.appointmentCount} termina' : null,
        isPositive: true,
        accentColor: AppColors.electric,
      ),
      StatCard(
        title: 'NEAKTIVNO OSOBLJE (30D)',
        value: '$inactive',
        trendValue: inactive > 0 ? 'bez ijednog termina' : 'svi aktivni',
        isPositive: inactive == 0,
        accentColor: inactive > 0 ? AppColors.warning : AppColors.success,
      ),
    ];

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.lg),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          cards[i],
        ],
      ],
    );
  }

  Widget _chartsRow(bool wide) {
    final rankingChart = _StaffRankingCard(ranking: report.staffRanking);
    final ringChart = _AppointmentTypeCard(report: report);

    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: rankingChart),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: ringChart),
          ],
        ),
      );
    }

    return Column(
      children: [
        rankingChart,
        const SizedBox(height: AppSpacing.lg),
        ringChart,
      ],
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// STAFF RANKING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _StaffRankingCard extends StatefulWidget {
  const _StaffRankingCard({required this.ranking});
  final List<StaffRankingItemDTO> ranking;

  @override
  State<_StaffRankingCard> createState() => _StaffRankingCardState();
}

class _StaffRankingCardState extends State<_StaffRankingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(_StaffRankingCard old) {
    super.didUpdateWidget(old);
    if (old.ranking != widget.ranking) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _staggered(int index) {
    final total = widget.ranking.length;
    if (total == 0) return 0;
    final start = index / total * 0.4;
    final t = ((_controller.value - start) / 0.6).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final ranking = widget.ranking;
    final maxVal = ranking.isEmpty
        ? 0
        : ranking.map((r) => r.appointmentCount).reduce((a, b) => a > b ? a : b);

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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child:
                    const Icon(LucideIcons.users, size: 18, color: AppColors.cyan),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rang lista osoblja', style: AppTextStyles.headingSm),
                    Text('Po broju termina (30d)',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (ranking.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('Nema podataka', style: AppTextStyles.bodyMd),
              ),
            )
          else
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < ranking.length; i++) ...[
                      _RankRow(
                        rank: i + 1,
                        item: ranking[i],
                        fraction: maxVal > 0 ? ranking[i].appointmentCount / maxVal : 0,
                        progress: _staggered(i),
                      ),
                      if (i < ranking.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.item,
    required this.fraction,
    required this.progress,
  });

  final int rank;
  final StaffRankingItemDTO item;
  final double fraction;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isTrainer = item.type == 'Trener';
    final color = isTrainer ? AppColors.cyan : AppColors.electric;
    final isTop = rank == 1;

    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '#$rank',
            style: AppTextStyles.caption.copyWith(
              color: isTop ? color : AppColors.textMuted,
              fontWeight: isTop ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(
            item.name,
            style: AppTextStyles.bodyMd.copyWith(
              color: isTop ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (fraction * progress).clamp(0.0, 1.0),
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  gradient: isTop
                      ? LinearGradient(colors: [color, color.withValues(alpha: 0.5)])
                      : null,
                  color: isTop ? null : color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 28,
          child: Text(
            '${item.appointmentCount}',
            style: AppTextStyles.bodySm.copyWith(
              color: isTop ? color : AppColors.textMuted,
              fontWeight: isTop ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APPOINTMENT TYPE RING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentTypeCard extends StatelessWidget {
  const _AppointmentTypeCard({required this.report});
  final StaffReportDTO report;

  @override
  Widget build(BuildContext context) {
    final total = report.totalAppointments;
    final trainerPct = total > 0
        ? '${(report.trainerAppointments / total * 100).toStringAsFixed(0)}%'
        : '0%';
    final nutritionistPct = total > 0
        ? '${(report.nutritionistAppointments / total * 100).toStringAsFixed(0)}%'
        : '0%';

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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.electric.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(LucideIcons.pieChart,
                    size: 18, color: AppColors.electric),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Struktura termina', style: AppTextStyles.headingSm),
                    Text('Treninzi vs konsultacije',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: RingChart(
              centerLabel: 'Ukupno',
              centerValue: '$total',
              showLegend: false,
              segments: [
                RingSegment(
                  label: 'Treninzi',
                  value: report.trainerAppointments.toDouble(),
                  color: AppColors.cyan,
                ),
                RingSegment(
                  label: 'Konsultacije',
                  value: report.nutritionistAppointments.toDouble(),
                  color: AppColors.electric,
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RingChartLegendItem(
                color: AppColors.cyan,
                label: 'Treninzi',
                value: '${report.trainerAppointments}',
                pct: trainerPct,
              ),
              const SizedBox(width: AppSpacing.xl),
              RingChartLegendItem(
                color: AppColors.electric,
                label: 'Konsultacije',
                value: '${report.nutritionistAppointments}',
                pct: nutritionistPct,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────

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
