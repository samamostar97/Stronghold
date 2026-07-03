import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/staff_member.dart';
import '../models/user.dart';
import '../providers/appointments_provider.dart';
import '../providers/staff_provider.dart';
import '../providers/users_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/status_chip.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _searchController = TextEditingController();

  static const _statusLabels = {
    'Pending': 'Na čekanju',
    'Confirmed': 'Potvrđen',
    'Completed': 'Održan',
    'Cancelled': 'Otkazan',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppointmentsProvider>().load(
          page: 1, searchText: '', clearStatus: true, clearDate: true),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  StatusTone _statusTone(String status) => switch (status) {
        'Confirmed' => StatusTone.success,
        'Completed' => StatusTone.info,
        'Cancelled' => StatusTone.danger,
        _ => StatusTone.warning,
      };

  Future<void> _openAddDialog() async {
    final users = await context.read<UsersProvider>().loadAll();
    if (!mounted) return;
    final staff = await context.read<StaffProvider>().loadAll();
    if (!mounted) return;

    final members = users.where((u) => u.role == 'GymMember').toList();
    if (members.isEmpty || staff.isEmpty) {
      _showError('Potrebni su članovi i osoblje da bi se dodao termin.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    User? selectedMember;
    StaffMember? selectedStaff;
    DateTime? selectedDate;
    List<int>? freeSlots;
    int? selectedHour;
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> loadSlots() async {
            if (selectedStaff == null || selectedDate == null) return;
            final slots = await context
                .read<AppointmentsProvider>()
                .loadFreeSlots(selectedStaff!.id, selectedDate!);
            setDialogState(() {
              freeSlots = slots;
              selectedHour = null;
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                const Expanded(child: Text('Novi termin')),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<User>(
                      initialValue: selectedMember,
                      decoration: const InputDecoration(
                        labelText: 'Član',
                      ),
                      items: [
                        for (final member in members)
                          DropdownMenuItem(
                            value: member,
                            child: Text('${member.fullName} (${member.username})'),
                          ),
                      ],
                      validator: (value) =>
                          value == null ? 'Odaberite člana.' : null,
                      onChanged: (value) =>
                          setDialogState(() => selectedMember = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StaffMember>(
                      initialValue: selectedStaff,
                      decoration: const InputDecoration(
                        labelText: 'Trener / nutricionista',
                      ),
                      items: [
                        for (final member in staff)
                          DropdownMenuItem(
                            value: member,
                            child: Text(
                                '${member.fullName} (${member.staffType == 'Trainer' ? 'trener' : 'nutricionista'})'),
                          ),
                      ],
                      validator: (value) =>
                          value == null ? 'Odaberite osobu.' : null,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStaff = value;
                          freeSlots = null;
                          selectedHour = null;
                        });
                        loadSlots();
                      },
                    ),
                    const SizedBox(height: 16),
                    // shared date picker - isti obrazac koriste i seminari
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(selectedDate == null
                          ? 'Odaberite datum'
                          : Formatters.date(selectedDate!)),
                      onPressed: selectedStaff == null
                          ? null
                          : () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: now.add(const Duration(days: 1)),
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 60)),
                              );
                              if (picked == null) return;
                              setDialogState(() {
                                selectedDate = picked;
                                freeSlots = null;
                                selectedHour = null;
                              });
                              await loadSlots();
                            },
                    ),
                    const SizedBox(height: 16),
                    // dropdown slobodnih satnica - zauzete su filtrirane na backendu
                    DropdownButtonFormField<int>(
                      key: ValueKey('slots-${selectedStaff?.id}-$selectedDate'),
                      initialValue: selectedHour,
                      decoration: InputDecoration(
                        labelText: freeSlots == null
                            ? 'Slobodna satnica (prvo osoba i datum)'
                            : freeSlots!.isEmpty
                                ? 'Nema slobodnih satnica'
                                : 'Slobodna satnica',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final hour in freeSlots ?? <int>[])
                          DropdownMenuItem(value: hour, child: Text('$hour:00')),
                      ],
                      validator: (value) =>
                          value == null ? 'Odaberite satnicu.' : null,
                      onChanged: (value) =>
                          setDialogState(() => selectedHour = value),
                    ),
                    if (serverError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        serverError!,
                        style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error),
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
                    await context.read<AppointmentsProvider>().create(
                          userId: selectedMember!.id,
                          staffMemberId: selectedStaff!.id,
                          date: selectedDate!,
                          startHour: selectedHour!,
                        );
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    _showSuccess('Termin je dodan.');
                  } on ApiException catch (e) {
                    setDialogState(() => serverError = e.message);
                  }
                },
                child: const Text('Dodaj termin'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancel(Appointment appointment) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Otkazivanje termina')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Otkazati termin: ${appointment.userFullName} kod '
                  '${appointment.staffFullName}, ${Formatters.date(appointment.date)} '
                  'u ${appointment.startHour}:00?',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Razlog otkazivanja',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite razlog otkazivanja.'
                      : null,
                ),
                if (serverError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    serverError!,
                    style:
                        TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                  ),
                ],
              ],
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
                      .read<AppointmentsProvider>()
                      .cancel(appointment.id, reasonController.text.trim());
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess('Termin je otkazan.');
                } on ApiException catch (e) {
                  setDialogState(() => serverError = e.message);
                }
              },
              child: const Text('Otkaži termin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus(int id, Future<void> Function(int) action,
      String successMessage) async {
    try {
      await action(id);
      _showSuccess(successMessage);
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 260,
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
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: provider.status,
              hint: const Text('Svi statusi'),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Svi statusi')),
                for (final entry in _statusLabels.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => value == null
                  ? provider.load(page: 1, clearStatus: true)
                  : provider.load(page: 1, status: value),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(provider.date == null
                  ? 'Svi datumi'
                  : Formatters.date(provider.date!)),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: provider.date ?? now,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  provider.load(page: 1, date: picked);
                }
              },
            ),
            if (provider.date != null)
              IconButton(
                tooltip: 'Ukloni filter datuma',
                icon: const Icon(Icons.clear),
                onPressed: () => provider.load(page: 1, clearDate: true),
              ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novi termin'),
              onPressed: _openAddDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.appointments.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema termina za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Član')),
                              DataColumn(label: Text('Osoblje')),
                              DataColumn(label: Text('Datum')),
                              DataColumn(label: Text('Satnica')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final appointment in provider.appointments)
                                DataRow(cells: [
                                  DataCell(Text(appointment.userFullName)),
                                  DataCell(Text(appointment.staffFullName)),
                                  DataCell(Text(Formatters.date(appointment.date))),
                                  DataCell(Text('${appointment.startHour}:00')),
                                  DataCell(Tooltip(
                                    message: appointment.status == 'Cancelled'
                                        ? 'Otkazao: ${appointment.cancelledBy == 'Admin' ? 'administrator' : 'član'}'
                                            '${appointment.cancellationReason != null ? ' - ${appointment.cancellationReason}' : ''}'
                                        : '',
                                    child: StatusChip(
                                      label: _statusLabels[appointment.status] ??
                                          appointment.status,
                                      tone: _statusTone(appointment.status),
                                    ),
                                  )),
                                  DataCell(Row(children: [
                                    if (appointment.status == 'Pending')
                                      IconButton(
                                        tooltip: 'Potvrdi termin',
                                        icon: const Icon(
                                            Icons.check_circle_outline),
                                        onPressed: () => _changeStatus(
                                            appointment.id,
                                            context
                                                .read<AppointmentsProvider>()
                                                .confirm,
                                            'Termin je potvrđen.'),
                                      ),
                                    if (appointment.status == 'Confirmed')
                                      IconButton(
                                        tooltip: 'Označi kao održan',
                                        icon: const Icon(Icons.task_alt),
                                        onPressed: () => _changeStatus(
                                            appointment.id,
                                            context
                                                .read<AppointmentsProvider>()
                                                .complete,
                                            'Termin je označen kao održan.'),
                                      ),
                                    if (appointment.status == 'Pending' ||
                                        appointment.status == 'Confirmed')
                                      IconButton(
                                        tooltip: 'Otkaži termin',
                                        icon: const Icon(Icons.cancel_outlined),
                                        onPressed: () => _cancel(appointment),
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
