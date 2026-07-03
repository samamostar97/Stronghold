import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';
import '../utils/api_client.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import '../widgets/stretch_scroll.dart';

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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.navyTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: AppTheme.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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

  String _actionLabel(String action) => switch (action) {
        'Create' => 'dodao',
        'Update' => 'izmijenio',
        'Delete' => 'obrisao',
        _ => action,
      };

  String _entityLabel(String entityName) => switch (entityName) {
        'City' => 'grad',
        'MembershipPackage' => 'paket',
        'SupplementCategory' => 'kategoriju',
        'Supplier' => 'dobavljača',
        'Supplement' => 'suplement',
        'Faq' => 'FAQ pitanje',
        'StaffMember' => 'osoblje',
        'Seminar' => 'seminar',
        _ => entityName,
      };

  Future<void> _undo(int id) async {
    try {
      await context.read<ReportsProvider>().undoActivity(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akcija je poništena.')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final dashboard = provider.dashboard;

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
                : StretchScroll(
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
                            DataCell(StatusChip(
                              label: _statusLabel(order.status),
                              tone: switch (order.status) {
                                'Delivered' => StatusTone.success,
                                'Cancelled' => StatusTone.danger,
                                _ => StatusTone.warning,
                              },
                            )),
                          ]),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Text('Nedavne aktivnosti', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: provider.activities.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Još nema zabilježenih aktivnosti.')),
                  )
                : Column(
                    children: [
                      for (final activity in provider.activities)
                        ListTile(
                          dense: true,
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.navyTint,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              switch (activity.action) {
                                'Create' => Icons.add_circle_outline,
                                'Update' => Icons.edit_outlined,
                                _ => Icons.delete_outline,
                              },
                              size: 17,
                              color: AppTheme.navy,
                            ),
                          ),
                          title: Text(
                            '${activity.performedByName} je '
                            '${_actionLabel(activity.action)} '
                            '${_entityLabel(activity.entityName)}'
                            '${activity.entityDisplay != null ? ' "${activity.entityDisplay}"' : ''}',
                          ),
                          subtitle: Text(Formatters.dateTime(activity.timestamp)),
                          trailing: activity.canUndo
                              ? TextButton.icon(
                                  icon: const Icon(Icons.undo, size: 18),
                                  label: const Text('Poništi'),
                                  onPressed: () => _undo(activity.id),
                                )
                              : const Tooltip(
                                  message:
                                      'Undo je moguć samo 1 sat nakon akcije',
                                  child: TextButton(
                                    onPressed: null,
                                    child: Text('Poništi'),
                                  ),
                                ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
