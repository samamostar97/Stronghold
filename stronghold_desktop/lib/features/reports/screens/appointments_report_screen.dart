import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/export_buttons.dart';
import '../widgets/report_stat_card.dart';

class AppointmentsReportScreen extends ConsumerWidget {
  const AppointmentsReportScreen({super.key});

  String _staffTypeLabel(String type) {
    switch (type) {
      case 'Trainer':
        return 'Trener';
      case 'Nutritionist':
        return 'Nutricionista';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(appointmentDateRangeProvider);
    final dataAsync = ref.watch(appointmentsReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('Izvjestaji - Termini', style: AppTextStyles.h2)),
              ReportDateRangePicker(
                from: range.from,
                to: range.to,
                onFromChanged: (d) => ref
                    .read(appointmentDateRangeProvider.notifier)
                    .update(range.copyWith(from: d)),
                onToChanged: (d) => ref
                    .read(appointmentDateRangeProvider.notifier)
                    .update(range.copyWith(to: d)),
              ),
              const SizedBox(width: 12),
              ExportButtons(
                endpoint: 'appointments',
                fileBaseName: 'termini',
                dateRangeProvider: appointmentDateRangeProvider,
              ),
            ],
          ),

          const SizedBox(height: 24),

          dataAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) =>
                _buildError(() => ref.invalidate(appointmentsReportProvider)),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ReportStatCard(
                        label: 'Ukupno termina',
                        value: '${data.totalAppointments}',
                        icon: Icons.calendar_today_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 24),

                Text('Statistike po osoblju', style: AppTextStyles.h3),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.sidebar,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            _HeaderCell('OSOBLJE', flex: 3),
                            _HeaderCell('TIP', flex: 2),
                            _HeaderCell('UKUPNO', flex: 1),
                            _HeaderCell('ZAVRSENO', flex: 1),
                            _HeaderCell('ODOBRENO', flex: 1),
                            _HeaderCell('ODBIJENO', flex: 1),
                            _HeaderCell('NA CEKANJU', flex: 1),
                          ],
                        ),
                      ),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1),
                      if (data.staffStats.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                                'Nema termina u odabranom periodu',
                                style: AppTextStyles.bodySmall),
                          ),
                        )
                      else
                        ...data.staffStats.map((s) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(s.staffName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(fontSize: 13)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        _staffTypeLabel(s.staffType),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(fontSize: 12)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text('${s.totalAppointments}',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(fontSize: 13)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _StatBadge(
                                        value: s.completed,
                                        color: AppColors.success),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _StatBadge(
                                        value: s.approved,
                                        color: AppColors.info),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _StatBadge(
                                        value: s.rejected,
                                        color: AppColors.error),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _StatBadge(
                                        value: s.pending,
                                        color: AppColors.warning),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

class _StatBadge extends StatelessWidget {
  final int value;
  final Color color;

  const _StatBadge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return Text('0',
          style: AppTextStyles.bodySmall
              .copyWith(fontSize: 12, color: AppColors.textSecondary));
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$value',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
