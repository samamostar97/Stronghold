import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/export_buttons.dart';
import '../widgets/report_stat_card.dart';

class RevenueReportScreen extends ConsumerWidget {
  const RevenueReportScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Potvrdjeno';
      case 'Shipped':
        return 'Poslano';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(revenueDateRangeProvider);
    final revenueAsync = ref.watch(revenueReportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(child: Text('Izvjestaji - Prihodi', style: AppTextStyles.h2)),
              ReportDateRangePicker(
                from: range.from,
                to: range.to,
                onFromChanged: (d) => ref
                    .read(revenueDateRangeProvider.notifier)
                    .update(range.copyWith(from: d)),
                onToChanged: (d) => ref
                    .read(revenueDateRangeProvider.notifier)
                    .update(range.copyWith(to: d)),
              ),
              const SizedBox(width: 12),
              ExportButtons(
                endpoint: 'revenue',
                fileBaseName: 'prihodi',
                dateRangeProvider: revenueDateRangeProvider,
              ),
            ],
          ),

          const SizedBox(height: 24),

          revenueAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => _buildError(ref),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: ReportStatCard(
                        label: 'Ukupni prihodi',
                        value: '${data.totalRevenue.toStringAsFixed(2)} KM',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReportStatCard(
                        label: 'Prihodi od narudzbi',
                        value: '${data.orderRevenue.toStringAsFixed(2)} KM',
                        icon: Icons.shopping_bag_outlined,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReportStatCard(
                        label: 'Prihodi od clanarina',
                        value: '${data.membershipRevenue.toStringAsFixed(2)} KM',
                        icon: Icons.card_membership_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Orders table
                Text('Narudzbe', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildTable(
                  headers: ['ID', 'Korisnik', 'Iznos', 'Status', 'Datum'],
                  rows: data.orderItems
                      .map((o) => [
                            '#${o.orderId}',
                            o.userName,
                            '${o.totalAmount.toStringAsFixed(2)} KM',
                            _statusLabel(o.status),
                            _formatDate(o.createdAt),
                          ])
                      .toList(),
                  emptyMessage: 'Nema narudzbi u odabranom periodu',
                ),

                const SizedBox(height: 32),

                // Memberships table
                Text('Clanarine', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildTable(
                  headers: ['ID', 'Korisnik', 'Paket', 'Cijena', 'Pocetak', 'Kraj'],
                  rows: data.membershipItems
                      .map((m) => [
                            '#${m.membershipId}',
                            m.userName,
                            m.packageName,
                            '${m.price.toStringAsFixed(2)} KM',
                            _formatDate(m.startDate),
                            _formatDate(m.endDate),
                          ])
                      .toList(),
                  emptyMessage: 'Nema clanarina u odabranom periodu',
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
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: TextButton(
          onPressed: () => ref.invalidate(revenueReportProvider),
          child: Text('Pokusaj ponovo',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
    required String emptyMessage,
  }) {
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
              children: headers
                  .map((h) => Expanded(
                        child: Text(h,
                            style: AppTextStyles.label.copyWith(fontSize: 11)),
                      ))
                  .toList(),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(emptyMessage, style: AppTextStyles.bodySmall),
              ),
            )
          else
            ...rows.map((row) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: row
                        .map((cell) => Expanded(
                              child: Text(
                                cell,
                                style: AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                  ),
                )),
        ],
      ),
    );
  }
}
