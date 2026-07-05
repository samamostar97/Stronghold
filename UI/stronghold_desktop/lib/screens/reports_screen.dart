import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_models.dart';
import '../providers/reports_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';

/// Biznis report: tabovi Prihodi / Inventar / Clanarine, svaki sa PDF i Excel exportom.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabKeys = ['revenue', 'inventory', 'memberships'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportsProvider>().loadReports(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message), backgroundColor: Colors.red.shade700),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Prihodi'),
                  Tab(text: 'Inventar'),
                  Tab(text: 'Članarine'),
                ],
              ),
            ),
            const SizedBox(width: 16),
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
              _inventoryTab(provider.inventory),
              _membershipsTab(provider.memberships),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ukupno članarine: ${Formatters.money(report.totalMembershipRevenue)}    '
                  'Ukupno prodavnica: ${Formatters.money(report.totalOrderRevenue)}    '
                  'UKUPNO: ${Formatters.money(report.totalMembershipRevenue + report.totalOrderRevenue)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
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
                Text('Najprodavaniji proizvodi',
                    style: Theme.of(context).textTheme.titleMedium),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Proizvod')),
                    DataColumn(label: Text('Prodano')),
                    DataColumn(label: Text('Prihod')),
                  ],
                  rows: [
                    for (final product in report.topProducts)
                      DataRow(cells: [
                        DataCell(Text(product.name)),
                        DataCell(Text('${product.quantitySold} kom')),
                        DataCell(Text(Formatters.money(product.revenue))),
                      ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inventoryTab(InventoryReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ukupna vrijednost zaliha: ${Formatters.money(report.totalValue)}    '
              'Artikala sa niskim zalihama (<10): ${report.lowStockCount}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Proizvod')),
                DataColumn(label: Text('Kategorija')),
                DataColumn(label: Text('Dobavljač')),
                DataColumn(label: Text('Zalihe')),
                DataColumn(label: Text('Cijena')),
                DataColumn(label: Text('Vrijednost')),
              ],
              rows: [
                for (final item in report.items)
                  DataRow(cells: [
                    DataCell(SizedBox(
                      width: 220,
                      child: Text(item.name, overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(item.categoryName)),
                    DataCell(Text(item.supplierName)),
                    DataCell(Text(
                      '${item.stockQuantity}',
                      style: item.stockQuantity < 10
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold)
                          : null,
                    )),
                    DataCell(Text(Formatters.money(item.price))),
                    DataCell(Text(Formatters.money(item.stockValue))),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _membershipsTab(MembershipReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aktivnih članova: ${report.activeCount}    '
              'Ističe u narednih 7 dana: ${report.expiringIn7Days}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aktivne članarine po paketima',
                          style: Theme.of(context).textTheme.titleMedium),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Paket')),
                          DataColumn(label: Text('Aktivnih')),
                        ],
                        rows: [
                          for (final package in report.byPackage)
                            DataRow(cells: [
                              DataCell(Text(package.packageName)),
                              DataCell(Text('${package.activeCount}')),
                            ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Posjećenost po sedmicama',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _barChart(
                        [
                          for (final week in report.weeklyVisits)
                            ('${week.weekStart.day}.${week.weekStart.month}.',
                                week.count.toDouble()),
                        ],
                        Theme.of(context).colorScheme.tertiary,
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
}
