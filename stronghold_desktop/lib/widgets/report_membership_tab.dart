import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import 'data_table_widgets.dart';
import 'gradient_button.dart';
import 'report_export_button.dart';
import 'shimmer_loading.dart';

/// Membership popularity tab content for the report screen.
class ReportMembershipTab extends ConsumerWidget {
  const ReportMembershipTab({
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
    final async = ref.watch(membershipPopularityReportProvider);
    return async.when(
      loading: () => const ShimmerDashboard(),
      error: (error, _) => _ErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(membershipPopularityReportProvider),
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

  final MembershipPopularityReportDTO report;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final topPlan =
        report.planStats.isNotEmpty ? report.planStats.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _exportRow(),
          const SizedBox(height: AppSpacing.xl),
          _summaryCards(),
          const SizedBox(height: AppSpacing.xxl),
          if (topPlan != null) ...[
            _TopPlanCard(plan: topPlan),
            const SizedBox(height: AppSpacing.xxl),
          ],
          _plansTable(),
        ],
      ),
    );
  }

  Widget _exportRow() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ReportExportButton.excel(onPressed: onExportExcel),
          const SizedBox(width: AppSpacing.md),
          ReportExportButton.pdf(onPressed: onExportPdf),
        ],
      );

  Widget _summaryCards() => Row(children: [
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.users,
            label: 'Aktivnih clanarina',
            value: '${report.totalActiveMemberships}',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.banknote,
            label: 'Prihod (90 dana)',
            value: '${report.totalRevenueLast90Days.toStringAsFixed(2)} KM',
            color: AppColors.success,
          ),
        ),
      ]);

  Widget _plansTable() => Container(
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
              child: Text('Statistika po paketima',
                  style: AppTextStyles.headingSm),
            ),
            if (report.planStats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Center(
                  child: Text('Nema aktivnih paketa',
                      style: AppTextStyles.bodyMd),
                ),
              )
            else
              _MembershipStatsTable(plans: report.planStats),
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

class _TopPlanCard extends StatelessWidget {
  const _TopPlanCard({required this.plan});
  final MembershipPlanStatsDTO plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.accentLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(LucideIcons.trophy, color: AppColors.accent, size: 32),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NAJPOPULARNIJI PAKET', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Text(plan.packageName,
                  style: AppTextStyles.statLg.copyWith(fontSize: 24),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xxl,
                runSpacing: AppSpacing.sm,
                children: [
                  _MiniStat(
                      label: 'Aktivnih',
                      value: '${plan.activeSubscriptions}'),
                  _MiniStat(
                      label: 'Popularnost',
                      value:
                          '${plan.popularityPercentage.toStringAsFixed(1)}%'),
                  _MiniStat(
                      label: 'Prihod',
                      value:
                          '${plan.revenueLast90Days.toStringAsFixed(0)} KM'),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    );
  }
}

class _MembershipStatsTable extends StatelessWidget {
  const _MembershipStatsTable({required this.plans});
  final List<MembershipPlanStatsDTO> plans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(children: [
            TableHeader(
              child: Row(children: [
                TableHeaderCell(text: 'Paket', flex: 3),
                TableHeaderCell(text: 'Cijena', flex: 2),
                TableHeaderCell(text: 'Aktivnih', flex: 1),
                TableHeaderCell(text: 'Novih', flex: 1),
                TableHeaderCell(
                    text: 'Prihod (90d)', flex: 2, alignRight: true),
                TableHeaderCell(
                    text: 'Popularnost', flex: 2, alignRight: true),
              ]),
            ),
            ...plans.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return HoverableTableRow(
                index: i,
                isLast: i == plans.length - 1,
                child: Row(children: [
                  TableDataCell(text: p.packageName, flex: 3, bold: true),
                  TableDataCell(
                      text: '${p.packagePrice.toStringAsFixed(2)} KM',
                      flex: 2,
                      muted: true),
                  TableDataCell(
                      text: '${p.activeSubscriptions}', flex: 1, bold: true),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.newSubscriptionsLast30Days > 0)
                          Icon(LucideIcons.arrowUp,
                              color: AppColors.success, size: 14),
                        Expanded(
                          child: Text(
                            '${p.newSubscriptionsLast30Days}',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: p.newSubscriptionsLast30Days > 0
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${p.revenueLast90Days.toStringAsFixed(2)} KM',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_popBadge(p.popularityPercentage.toDouble())],
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

  Widget _popBadge(double pct) {
    final color = pct >= 30
        ? AppColors.success
        : pct >= 10
            ? AppColors.orange
            : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text('${pct.toStringAsFixed(1)}%',
          style: AppTextStyles.badge.copyWith(color: color)),
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
        GradientButton(text: 'Pokusaj ponovo', onTap: onRetry),
      ]),
    );
  }
}
