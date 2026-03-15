import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/export_buttons.dart';
import '../widgets/report_stat_card.dart';

class UsersReportScreen extends ConsumerWidget {
  const UsersReportScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(userDateRangeProvider);
    final dataAsync = ref.watch(usersReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Izvjestaji - Korisnici', style: AppTextStyles.h2)),
              ReportDateRangePicker(
                from: range.from,
                to: range.to,
                onFromChanged: (d) => ref
                    .read(userDateRangeProvider.notifier)
                    .update(range.copyWith(from: d)),
                onToChanged: (d) => ref
                    .read(userDateRangeProvider.notifier)
                    .update(range.copyWith(to: d)),
              ),
              const SizedBox(width: 12),
              ExportButtons(
                endpoint: 'users',
                fileBaseName: 'korisnici',
                dateRangeProvider: userDateRangeProvider,
              ),
            ],
          ),

          const SizedBox(height: 24),

          dataAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => _buildError(
                () => ref.invalidate(usersReportProvider)),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ReportStatCard(
                        label: 'Novi korisnici',
                        value: '${data.totalNewUsers}',
                        icon: Icons.person_add_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 24),

                Text('Registrovani korisnici', style: AppTextStyles.h3),
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
                            _HeaderCell('ID', width: 70),
                            _HeaderCell('Ime i prezime', flex: 2),
                            _HeaderCell('Email', flex: 2),
                            _HeaderCell('Datum registracije', flex: 1),
                          ],
                        ),
                      ),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1),
                      if (data.users.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text('Nema novih korisnika u odabranom periodu',
                                style: AppTextStyles.bodySmall),
                          ),
                        )
                      else
                        ...data.users.map((u) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text('#${u.id}',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                                fontSize: 13,
                                                color: AppColors.primary)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(u.fullName,
                                        style: AppTextStyles.body
                                            .copyWith(fontSize: 13)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(u.email,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(fontSize: 12)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(_formatDate(u.createdAt),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(fontSize: 12)),
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
