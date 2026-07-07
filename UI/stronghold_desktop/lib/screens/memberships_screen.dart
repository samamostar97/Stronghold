import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/membership.dart';
import '../providers/memberships_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/packages_provider.dart';
import '../providers/payments_provider.dart';
import '../providers/users_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/status_chip.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key});

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final intent =
          context.read<NavigationProvider>().takeIntent(NavTarget.memberships);
      context
          .read<MembershipsProvider>()
          .load(page: 1, searchText: '', onlyActive: false);
      if (intent?.action == 'create') _openAssignDialog();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAssignDialog() async {
    final users = await context.read<UsersProvider>().loadAll();
    if (!mounted) return;
    final packages = await context.read<PackagesProvider>().loadAll();
    if (!mounted) return;

    final members = users.where((u) => u.role == 'GymMember').toList();
    if (members.isEmpty || packages.isEmpty) {
      _showSuccess('Prvo dodajte članove i pakete članarina.');
      return;
    }

    int? selectedUserId;
    int? selectedPackageId;
    String? serverError;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Dodaj uplatu / dodijeli članarinu')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedUserId,
                    decoration: const InputDecoration(
                      labelText: 'Član',
                    ),
                    items: [
                      for (final member in members)
                        DropdownMenuItem(
                          value: member.id,
                          child: Text('${member.fullName} (${member.username})'),
                        ),
                    ],
                    validator: (value) => value == null ? 'Odaberite člana.' : null,
                    onChanged: (value) => setDialogState(() => selectedUserId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedPackageId,
                    decoration: const InputDecoration(
                      labelText: 'Paket članarine',
                    ),
                    items: [
                      for (final package in packages)
                        DropdownMenuItem(
                          value: package.id,
                          child: Text(
                            '${package.name} - ${Formatters.money(package.price)} / ${package.durationDays} dana',
                          ),
                        ),
                    ],
                    validator: (value) => value == null ? 'Odaberite paket.' : null,
                    onChanged: (value) =>
                        setDialogState(() => selectedPackageId = value),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Uplata iznosa paketa se evidentira odmah, a članarina se '
                    'aktivira ili produžava od isteka postojeće.',
                    style: TextStyle(fontSize: 12),
                  ),
                  if (serverError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      serverError!,
                      style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await context.read<MembershipsProvider>().assign(
                        userId: selectedUserId!,
                        packageId: selectedPackageId!,
                      );
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess('Uplata je evidentirana i članarina aktivirana.');
                } on ApiException catch (e) {
                  setDialogState(() => serverError = e.message);
                }
              },
              child: const Text('Evidentiraj uplatu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRevokeDialog(Membership membership) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Ukidanje članarine')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Prijevremeno ukidanje članarine za: ${membership.userFullName} '
                    '(${membership.packageName})',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Razlog ukidanja',
                    ),
                    maxLines: 2,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Unesite razlog ukidanja.'
                        : null,
                  ),
                  if (serverError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      serverError!,
                      style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await context
                      .read<MembershipsProvider>()
                      .revoke(membership.id, reasonController.text.trim());
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess('Članarina je ukinuta.');
                } on ApiException catch (e) {
                  setDialogState(() => serverError = e.message);
                }
              },
              child: const Text('Ukini članarinu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserPayments(Membership membership) async {
    final payments =
        await context.read<PaymentsProvider>().loadForUser(membership.userId);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('Uplate - ${membership.userFullName}')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: payments.isEmpty
              ? const Text('Korisnik nema evidentiranih uplata.')
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Datum')),
                      DataColumn(label: Text('Paket')),
                      DataColumn(label: Text('Iznos')),
                    ],
                    rows: [
                      for (final payment in payments)
                        DataRow(cells: [
                          DataCell(Text(Formatters.dateTime(payment.paidAt))),
                          DataCell(Text(payment.packageName)),
                          DataCell(Text(Formatters.money(payment.amount))),
                        ]),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _statusChip(Membership membership) {
    if (membership.isRevoked) {
      return const StatusChip(label: 'Ukinuta', tone: StatusTone.warning);
    }
    if (membership.isActive) {
      // aktivne clanarine su vizuelno naglasene
      return const StatusChip(label: 'Aktivna', tone: StatusTone.success);
    }
    return const StatusChip(label: 'Istekla', tone: StatusTone.neutral);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembershipsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga po članu',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
            const SizedBox(width: 16),
            FilterChip(
              label: const Text('Samo aktivne'),
              selected: provider.onlyActive,
              onSelected: (selected) =>
                  provider.load(page: 1, onlyActive: selected),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add_card),
              label: const Text('Dodaj uplatu'),
              onPressed: _openAssignDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.memberships.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema članarina za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Član')),
                              DataColumn(label: Text('Paket')),
                              DataColumn(label: Text('Vrijedi od')),
                              DataColumn(label: Text('Vrijedi do')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final membership in provider.memberships)
                                DataRow(cells: [
                                  DataCell(Text(membership.userFullName)),
                                  DataCell(Text(membership.packageName)),
                                  DataCell(Text(Formatters.date(membership.startDate))),
                                  DataCell(Text(Formatters.date(membership.endDate))),
                                  DataCell(_statusChip(membership)),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Historija uplata',
                                      icon: const Icon(Icons.receipt_long_outlined),
                                      onPressed: () => _showUserPayments(membership),
                                    ),
                                    IconButton(
                                      tooltip: membership.isActive
                                          ? 'Ukini članarinu'
                                          : 'Samo aktivna članarina se može ukinuti',
                                      icon: const Icon(Icons.cancel_outlined),
                                      onPressed: membership.isActive
                                          ? () => _openRevokeDialog(membership)
                                          : null,
                                    ),
                                  ])),
                                ]),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 8),
        PaginationBar(
          page: provider.page,
          pageSize: provider.pageSize,
          totalCount: provider.totalCount,
          onPageChanged: (page) => provider.load(page: page),
        ),
      ],
    );
  }
}
