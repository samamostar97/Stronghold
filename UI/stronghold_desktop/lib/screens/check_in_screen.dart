import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/visits_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<VisitsProvider>().load(historyPage: 1),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _openCheckInDialog() async {
    List<User> eligible = await context.read<VisitsProvider>().loadEligible('');
    if (!mounted) return;
    final searchController = TextEditingController();
    String? serverError;
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Check-in korisnika')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Pretraga člana',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onSubmitted: (value) async {
                    final results = await context
                        .read<VisitsProvider>()
                        .loadEligible(value.trim());
                    setDialogState(() => eligible = results);
                  },
                ),
                const SizedBox(height: 8),
                if (serverError != null)
                  Text(
                    serverError!,
                    style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                  ),
                Expanded(
                  child: eligible.isEmpty
                      ? const Center(
                          child: Text(
                            'Nema članova sa aktivnom članarinom\nkoji nisu već u teretani.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: eligible.length,
                          itemBuilder: (listContext, index) {
                            final member = eligible[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(member.firstName[0])),
                              title: Text(member.fullName),
                              subtitle: Text(member.username),
                              trailing: FilledButton(
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        setDialogState(() {
                                          submitting = true;
                                          serverError = null;
                                        });
                                        try {
                                          await context
                                              .read<VisitsProvider>()
                                              .checkIn(member.id);
                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop();
                                          }
                                          _showSuccess(
                                              '${member.fullName} je prijavljen u teretanu.');
                                        } on ApiException catch (e) {
                                          if (dialogContext.mounted) {
                                            setDialogState(() {
                                              serverError = e.message;
                                              submitting = false;
                                            });
                                          }
                                        }
                                      },
                                child: const Text('Check-in'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkOut(int visitId, String name) async {
    try {
      await context.read<VisitsProvider>().checkOut(visitId);
      _showSuccess('$name je odjavljen iz teretane.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Trenutno u teretani: ${provider.currentVisits.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Osvježi',
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.load(),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Check-in korisnika'),
              onPressed: _openCheckInDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.loading && provider.currentVisits.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else ...[
          SizedBox(
            height: 180,
            child: provider.currentVisits.isEmpty
                ? const Card(
                    child: Center(child: Text('Trenutno nema nikoga u teretani.')),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.currentVisits.length,
                    itemBuilder: (context, index) {
                      final visit = provider.currentVisits[index];
                      return Card(
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visit.userFullName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(visit.username),
                              const Spacer(),
                              Text('Ušao: ${Formatters.dateTime(visit.checkInAt)}'),
                              Text('U teretani: ${Formatters.duration(visit.durationMinutes)}'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Check-out'),
                                onPressed: () =>
                                    _checkOut(visit.id, visit.userFullName),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Text('Historija posjeta', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: StretchScroll(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Član')),
                      DataColumn(label: Text('Ulazak')),
                      DataColumn(label: Text('Izlazak')),
                      DataColumn(label: Text('Trajanje')),
                    ],
                    rows: [
                      for (final visit in provider.history)
                        DataRow(cells: [
                          DataCell(Text(visit.userFullName)),
                          DataCell(Text(Formatters.dateTime(visit.checkInAt))),
                          DataCell(Text(visit.checkOutAt != null
                              ? Formatters.dateTime(visit.checkOutAt!)
                              : 'U teretani')),
                          DataCell(Text(Formatters.duration(visit.durationMinutes))),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PaginationBar(
            page: provider.historyPage,
            pageSize: provider.historyPageSize,
            totalCount: provider.historyTotalCount,
            onPageChanged: (page) => provider.load(historyPage: page),
          ),
        ],
      ],
    );
  }
}
