import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';
import '../utils/formatters.dart';

/// Pocetni ekran - kljucne brojke i najnovije narudzbe.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportsProvider>().loadDashboard(),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'Processing' => 'U obradi',
        'Delivered' => 'Dostavljeno',
        'Cancelled' => 'Otkazano',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<ReportsProvider>().dashboard;

    if (dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReportsProvider>().loadDashboard(),
      child: ListView(
        children: [
          Row(
            children: [
              _statCard(Icons.people, '${dashboard.activeMembers}',
                  'aktivnih članova'),
              const SizedBox(width: 12),
              _statCard(Icons.today, '${dashboard.visitsToday}', 'posjeta danas'),
              const SizedBox(width: 12),
              _statCard(Icons.fitness_center, '${dashboard.currentlyInGym}',
                  'trenutno u teretani'),
              const SizedBox(width: 12),
              _statCard(Icons.payments, Formatters.money(dashboard.revenueThisMonth),
                  'prihod ovaj mjesec'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Najnovije narudžbe', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: dashboard.latestOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Još nema narudžbi.')),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Broj')),
                        DataColumn(label: Text('Kupac')),
                        DataColumn(label: Text('Datum')),
                        DataColumn(label: Text('Iznos')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: [
                        for (final order in dashboard.latestOrders)
                          DataRow(cells: [
                            DataCell(Text('#${order.id}')),
                            DataCell(Text(order.userFullName)),
                            DataCell(Text(Formatters.dateTime(order.createdAt))),
                            DataCell(Text(Formatters.money(order.totalAmount))),
                            DataCell(Text(_statusLabel(order.status))),
                          ]),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
