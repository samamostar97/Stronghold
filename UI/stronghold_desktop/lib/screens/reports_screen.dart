import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report_models.dart';
import '../models/user.dart';
import '../providers/reports_provider.dart';
import '../providers/users_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/stretch_scroll.dart';

/// Biznis report: vrsta izvještaja (Članarine / Prodavnica) za odabrani period
/// od-do datuma i opcionog člana, sa PDF i Excel exportom.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabKeys = ['memberships', 'shop'];

  /// Imena fajlova za export bez dijakritika.
  static const _fileSlugs = {'memberships': 'clanarine', 'shop': 'prodavnica'};

  List<User> _members = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReports();
      _loadMembers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final users = await context.read<UsersProvider>().loadAll();
    if (!mounted) return;
    setState(() {
      _members = users.where((u) => u.role == 'GymMember').toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _setFilters({
    DateTime? from,
    DateTime? to,
    int? userId,
    bool clearUser = false,
  }) async {
    final provider = context.read<ReportsProvider>();
    var newFrom = from ?? provider.fromDate;
    var newTo = to ?? provider.toDate;
    // granice se ne smiju mimoici - druga se povuce za odabranom
    if (newFrom.isAfter(newTo)) {
      if (from != null) {
        newTo = newFrom;
      } else {
        newFrom = newTo;
      }
    }
    try {
      await provider.setFilters(
        from: newFrom,
        to: newTo,
        userId: userId,
        clearUser: clearUser,
      );
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final provider = context.read<ReportsProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? provider.fromDate : provider.toDate,
      firstDate: now.subtract(const Duration(days: 3 * 365)),
      lastDate: now,
    );
    if (picked == null) return;
    await _setFilters(from: isFrom ? picked : null, to: isFrom ? null : picked);
  }

  Future<void> _export(String format) async {
    final reportKey = _tabKeys[_tabController.index];
    final extension = format == 'pdf' ? 'pdf' : 'xlsx';
    final fileName = 'stronghold-${_fileSlugs[reportKey]}.$extension';
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
      ],
    );
    if (location == null || !mounted) return;

    try {
      final bytes =
          await context.read<ReportsProvider>().downloadExport(reportKey, format);
      final file = XFile.fromData(Uint8List.fromList(bytes), name: fileName);
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

  Widget _dateButton({required String label, required bool isFrom}) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(label),
      onPressed: () => _pickDate(isFrom: isFrom),
    );
  }

  Widget _memberFilter(ReportsProvider provider) {
    return SizedBox(
      width: 240,
      child: DropdownButton<int?>(
        value: provider.memberUserId,
        isExpanded: true,
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Svi članovi')),
          for (final member in _members)
            DropdownMenuItem<int?>(
              value: member.id,
              child: Text(
                '${member.fullName} (${member.username})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) =>
            _setFilters(userId: value, clearUser: value == null),
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
            SizedBox(
              width: 260,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Članarine'),
                  Tab(text: 'Prodavnica'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _dateButton(
              label: 'Od: ${Formatters.date(provider.fromDate)}',
              isFrom: true,
            ),
            const SizedBox(width: 8),
            _dateButton(
              label: 'Do: ${Formatters.date(provider.toDate)}',
              isFrom: false,
            ),
            const SizedBox(width: 12),
            _memberFilter(provider),
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
              _membershipsTab(provider.memberships),
              _shopTab(provider.shop),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _membershipsTab(MembershipsReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (report.payments.isEmpty) {
      return const EmptyState(
        icon: Icons.card_membership,
        message: 'Nema uplata u odabranom periodu.',
      );
    }
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uplate članarina',
                    style: Theme.of(context).textTheme.titleMedium),
                StretchScroll(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Datum')),
                      DataColumn(label: Text('Član')),
                      DataColumn(label: Text('Paket')),
                      DataColumn(label: Text('Iznos')),
                    ],
                    rows: [
                      for (final payment in report.payments)
                        DataRow(cells: [
                          DataCell(Text(Formatters.date(payment.paidAt))),
                          DataCell(Text(payment.userFullName)),
                          DataCell(Text(payment.packageName)),
                          DataCell(Text(Formatters.money(payment.amount))),
                        ]),
                    ],
                  ),
                ),
                _totalLine(
                  'UKUPNO: ${Formatters.money(report.totalAmount)}  •  '
                  '${report.paymentCount} uplata',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shopTab(ShopReport? report) {
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (report.orders.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        message: 'Nema narudžbi u odabranom periodu.',
      );
    }
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prodaje u prodavnici',
                    style: Theme.of(context).textTheme.titleMedium),
                StretchScroll(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Datum')),
                      DataColumn(label: Text('Kupac')),
                      DataColumn(label: Text('Br. artikala')),
                      DataColumn(label: Text('Iznos')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      for (final order in report.orders)
                        DataRow(cells: [
                          DataCell(Text(Formatters.date(order.createdAt))),
                          DataCell(Text(order.userFullName)),
                          DataCell(Text('${order.itemCount}')),
                          DataCell(Text(Formatters.money(order.totalAmount))),
                          DataCell(Text(order.status)),
                        ]),
                    ],
                  ),
                ),
                _totalLine(
                  'UKUPNO: ${Formatters.money(report.totalRevenue)}  •  '
                  '${report.orderCount} narudžbi',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
