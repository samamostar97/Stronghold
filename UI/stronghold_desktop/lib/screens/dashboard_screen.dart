import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/reports_provider.dart';
import '../utils/api_client.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import '../widgets/stretch_scroll.dart';

/// Pocetni ekran - kljucne brojke, brze akcije, stavke koje traze paznju
/// i najnovije narudzbe.
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

  void _go(NavTarget target, {String? action, int? entityId}) {
    context
        .read<NavigationProvider>()
        .go(target, action: action, entityId: entityId);
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

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.navyTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: AppTheme.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _attentionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required int totalCount,
    required List<Widget> rows,
    required VoidCallback onOpen,
  }) {
    final hiddenCount = totalCount - rows.length;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 17, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$totalCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  IconButton(
                    tooltip: 'Otvori pregled',
                    icon: const Icon(Icons.arrow_forward,
                        size: 16, color: AppTheme.textSecondary),
                    onPressed: onOpen,
                  ),
                ],
              ),
              const Divider(height: 20),
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 17, color: AppTheme.success),
                      SizedBox(width: 8),
                      Text(
                        'Sve je pod kontrolom.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...rows,
                if (hiddenCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+ još $hiddenCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _attentionRow({
    required String primary,
    String? secondary,
    required String trailing,
    Color? trailingColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary != null)
                    Text(
                      secondary,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? AppTheme.textSecondary,
              ),
            ),
          ],
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
          const SizedBox(height: 12),
          Row(
            children: [
              _quickAction(Icons.login_outlined, 'Check-in člana',
                  () => _go(NavTarget.checkIn)),
              const SizedBox(width: 12),
              _quickAction(Icons.person_add_outlined, 'Novi korisnik',
                  () => _go(NavTarget.users, action: 'create')),
              const SizedBox(width: 12),
              _quickAction(Icons.add_card, 'Dodaj uplatu',
                  () => _go(NavTarget.memberships, action: 'create')),
              const SizedBox(width: 12),
              _quickAction(Icons.medication_outlined, 'Novi suplement',
                  () => _go(NavTarget.supplements, action: 'create')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Zahtijeva pažnju', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _attentionCard(
                icon: Icons.inventory_2_outlined,
                color: AppTheme.warning,
                title: 'Zalihe pri kraju',
                subtitle: 'suplementi sa manje od 10 komada',
                totalCount: dashboard.lowStockCount,
                onOpen: () => _go(NavTarget.supplements),
                rows: [
                  for (final item in dashboard.lowStockSupplements)
                    _attentionRow(
                      primary: item.name,
                      trailing: '${item.stockQuantity} kom',
                      trailingColor: item.stockQuantity == 0
                          ? AppTheme.danger
                          : AppTheme.warning,
                      onTap: () => _go(NavTarget.supplements),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              _attentionCard(
                icon: Icons.card_membership_outlined,
                color: AppTheme.navy,
                title: 'Članarine ističu',
                subtitle: 'u narednih 7 dana, bez obnove',
                totalCount: dashboard.expiringMembershipsCount,
                onOpen: () => _go(NavTarget.memberships),
                rows: [
                  for (final item in dashboard.expiringMemberships)
                    _attentionRow(
                      primary: item.userFullName,
                      secondary: item.packageName,
                      trailing: Formatters.date(item.endDate),
                      onTap: () => _go(NavTarget.memberships),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              _attentionCard(
                icon: Icons.hourglass_bottom_outlined,
                color: AppTheme.danger,
                title: 'Narudžbe čekaju',
                subtitle: 'u obradi duže od 3 dana',
                totalCount: dashboard.stuckOrdersCount,
                onOpen: () => _go(NavTarget.orders),
                rows: [
                  for (final order in dashboard.stuckOrders)
                    _attentionRow(
                      primary: '#${order.id} · ${order.userFullName}',
                      secondary: Formatters.money(order.totalAmount),
                      trailing: Formatters.date(order.createdAt),
                      onTap: () => _go(NavTarget.orders,
                          action: 'details', entityId: order.id),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Najnovije narudžbe',
                  style: Theme.of(context).textTheme.titleMedium),
              if (dashboard.newOrdersCount > 0) ...[
                const SizedBox(width: 10),
                StatusChip(
                  label: dashboard.newOrdersCount == 1
                      ? '1 nova'
                      : '${dashboard.newOrdersCount} novih',
                  tone: StatusTone.info,
                ),
              ],
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Prikaži sve'),
                onPressed: () => _go(NavTarget.orders),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: dashboard.latestOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Još nema narudžbi.')),
                  )
                : StretchScroll(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('Broj')),
                        DataColumn(label: Text('Kupac')),
                        DataColumn(label: Text('Datum')),
                        DataColumn(label: Text('Iznos')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: [
                        for (final order in dashboard.latestOrders)
                          DataRow(
                            // neotvorene narudzbe su blago naglasene
                            color: order.isNew
                                ? WidgetStatePropertyAll(
                                    AppTheme.navyTint.withValues(alpha: 0.45))
                                : null,
                            onSelectChanged: (_) => _go(NavTarget.orders,
                                action: 'details', entityId: order.id),
                            cells: [
                              DataCell(Row(
                                children: [
                                  Text('#${order.id}'),
                                  if (order.isNew) ...[
                                    const SizedBox(width: 8),
                                    const StatusChip(
                                        label: 'Novo', tone: StatusTone.info),
                                  ],
                                ],
                              )),
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
                            ],
                          ),
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
