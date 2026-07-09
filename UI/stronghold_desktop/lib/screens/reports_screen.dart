import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_models.dart';
import '../providers/reports_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import '../widgets/stretch_scroll.dart';

/// Biznis report: tabovi Prihodi / Osoblje za odabrani period (od-do mjeseca),
/// svaki sa PDF i Excel exportom.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabKeys = ['revenue', 'staff'];

  static const _monthNames = [
    'januar', 'februar', 'mart', 'april', 'maj', 'juni',
    'juli', 'august', 'septembar', 'oktobar', 'novembar', 'decembar',
  ];

  /// Ponudjeni mjeseci u dropdownima - zadnja 24, od najnovijeg.
  static List<DateTime> _monthOptions() {
    final current = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return List.generate(
        24, (i) => DateTime(current.year, current.month - i, 1));
  }

  static String _monthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportsProvider>().loadReports(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _changePeriod({DateTime? from, DateTime? to}) async {
    final provider = context.read<ReportsProvider>();
    var newFrom = from ?? provider.fromMonth;
    var newTo = to ?? provider.toMonth;
    // granice se ne smiju mimoici - druga se povuce za odabranom
    if (newFrom.isAfter(newTo)) {
      if (from != null) {
        newTo = newFrom;
      } else {
        newFrom = newTo;
      }
    }
    try {
      await provider.setPeriod(newFrom, newTo);
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  Future<void> _export(String format) async {
    final reportKey = _tabKeys[_tabController.index];
    final extension = format == 'pdf' ? 'pdf' : 'xlsx';
    final location = await getSaveLocation(
      suggestedName: 'stronghold-$reportKey.$extension',
      acceptedTypeGroups: [
        XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
      ],
    );
    if (location == null || !mounted) return;

    try {
      final bytes =
          await context.read<ReportsProvider>().downloadExport(reportKey, format);
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'stronghold-$reportKey.$extension',
      );
      await file.saveTo(location.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izvještaj je sačuvan: ${location.path}')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  Widget _barChart(List<(String label, double value)> data, Color color) {
    final max = data.fold<double>(0, (a, b) => b.$2 > a ? b.$2 : a);
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (label, value) in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(value == value.roundToDouble()
                        ? '${value.toInt()}'
                        : value.toStringAsFixed(0)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: max == 0 ? 0.02 : (value / max).clamp(0.02, 1),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(label, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _monthDropdown({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    final options = _monthOptions();
    // sigurnosno: vrijednost van ponude (npr. poslije ponoci) pada na najblizu
    final selected = options.firstWhere(
      (m) => m.year == value.year && m.month == value.month,
      orElse: () => options.first,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 6),
        DropdownButton<DateTime>(
          value: selected,
          items: [
            for (final month in options)
              DropdownMenuItem(value: month, child: Text(_monthLabel(month))),
          ],
          onChanged: (month) {
            if (month != null) onChanged(month);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 260,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Prihodi'),
                  Tab(text: 'Osoblje'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _monthDropdown(
              label: 'Od:',
              value: provider.fromMonth,
              onChanged: (month) => _changePeriod(from: month),
            ),
            const SizedBox(width: 12),
            _monthDropdown(
              label: 'Do:',
              value: provider.toMonth,
              onChanged: (month) => _changePeriod(to: month),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('PDF'),
              onPressed: () => _export('pdf'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.table_view_outlined, size: 18),
              label: const Text('Excel'),
              onPressed: () => _export('excel'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _revenueTab(provider.revenue),
              _staffTab(provider.staff),
            ],
          ),
        ),
      ],
    );
  }

  Widget _revenueTab(RevenueReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.payments,
                value: Formatters.money(report.totalRevenue),
                label: 'ukupan prihod',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.card_membership,
                value: Formatters.money(report.membershipRevenue),
                label: 'članarine',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.shopping_bag,
                value: Formatters.money(report.orderRevenue),
                label: 'prodavnica',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.person_add,
                value: '${report.newMembers}',
                label: 'novih članova',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.fitness_center,
                value: '${report.visitCount}',
                label: 'posjeta',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prihodi po mjesecima (KM)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _barChart(
                  [
                    for (final month in report.monthlyRevenue)
                      ('${month.month}/${month.year % 100}', month.total),
                  ],
                  Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mjesečni prihodi',
                    style: Theme.of(context).textTheme.titleMedium),
                StretchScroll(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Mjesec')),
                      DataColumn(label: Text('Članarine')),
                      DataColumn(label: Text('Prodavnica')),
                      DataColumn(label: Text('Ukupno')),
                    ],
                    rows: [
                      for (final month in report.monthlyRevenue)
                        DataRow(cells: [
                          DataCell(Text('${month.month}/${month.year}')),
                          DataCell(
                              Text(Formatters.money(month.membershipRevenue))),
                          DataCell(Text(Formatters.money(month.orderRevenue))),
                          DataCell(Text(Formatters.money(month.total))),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Najprodavaniji proizvodi',
                          style: Theme.of(context).textTheme.titleMedium),
                      StretchScroll(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Proizvod')),
                            DataColumn(label: Text('Kategorija')),
                            DataColumn(label: Text('Prodano')),
                            DataColumn(label: Text('Prihod')),
                          ],
                          rows: [
                            for (final product in report.topProducts)
                              DataRow(cells: [
                                DataCell(SizedBox(
                                  width: 220,
                                  child: Text(product.name,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Text(product.categoryName)),
                                DataCell(Text('${product.quantitySold} kom')),
                                DataCell(Text(Formatters.money(product.revenue))),
                              ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prodaja članarina po paketima',
                          style: Theme.of(context).textTheme.titleMedium),
                      StretchScroll(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Paket')),
                            DataColumn(label: Text('Prodano')),
                            DataColumn(label: Text('Prihod')),
                          ],
                          rows: [
                            for (final package in report.packageSales)
                              DataRow(cells: [
                                DataCell(Text(package.packageName)),
                                DataCell(Text('${package.soldCount}')),
                                DataCell(Text(Formatters.money(package.revenue))),
                              ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _staffTypeLabel(String staffType) =>
      staffType == 'Nutritionist' ? 'Nutricionista' : 'Trener';

  Widget _staffTab(StaffReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.event,
                value: '${report.totalAppointments}',
                label: 'termina u periodu',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.task_alt,
                value: '${report.completedCount}',
                label: 'održano',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.cancel_outlined,
                value: '${report.cancelledCount}',
                label: 'otkazano',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.schedule,
                value: '${report.upcomingCount}',
                label: 'nadolazećih',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.emoji_events,
                value: report.busiestStaffName == null
                    ? '—'
                    : '${report.busiestStaffName} (${report.busiestStaffCount})',
                label: 'najviše termina u periodu',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.access_time_filled,
                value: report.busiestHour == null
                    ? '—'
                    : '${report.busiestHour}:00 (${report.busiestHourCount})',
                label: 'najtraženija satnica',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Termini po osobi',
                    style: Theme.of(context).textTheme.titleMedium),
                StretchScroll(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Osoba')),
                      DataColumn(label: Text('Tip')),
                      DataColumn(label: Text('Zakazano')),
                      DataColumn(label: Text('Održano')),
                      DataColumn(label: Text('Otkazano')),
                      DataColumn(label: Text('Nadolazeći')),
                    ],
                    rows: [
                      for (final person in report.staff)
                        DataRow(cells: [
                          DataCell(Text(person.fullName)),
                          DataCell(Text(_staffTypeLabel(person.staffType))),
                          DataCell(Text('${person.totalCount}')),
                          DataCell(Text('${person.completedCount}')),
                          DataCell(Text('${person.cancelledCount}')),
                          DataCell(Text('${person.upcomingCount}')),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
