import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/seminar.dart';
import '../providers/seminars_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class SeminarsScreen extends StatefulWidget {
  const SeminarsScreen({super.key});

  @override
  State<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends State<SeminarsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SeminarsProvider>().load(page: 1, searchText: ''),
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

  Future<void> _openForm({Seminar? existing}) async {
    final formKey = GlobalKey<FormState>();
    final topicController = TextEditingController(text: existing?.topic ?? '');
    final speakerController = TextEditingController(text: existing?.speaker ?? '');
    final capacityController =
        TextEditingController(text: existing?.maxCapacity.toString() ?? '');
    DateTime? selectedDate = existing?.scheduledAt.toLocal();
    int selectedHour = existing?.scheduledAt.toLocal().hour ?? 18;
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(existing == null ? 'Novi seminar' : 'Izmjena seminara'),
              ),
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
                  TextFormField(
                    controller: topicController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Tema seminara',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Unesite temu seminara.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: speakerController,
                    decoration: const InputDecoration(
                      labelText: 'Predavač',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Unesite ime predavača.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // shared date picker + dropdown satnice (isti obrazac kao termini)
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(selectedDate == null
                            ? 'Odaberite datum'
                            : Formatters.date(selectedDate!)),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate:
                                selectedDate ?? now.add(const Duration(days: 7)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedHour,
                        decoration: const InputDecoration(
                          labelText: 'Satnica',
                          isDense: true,
                        ),
                        items: [
                          for (var hour = 8; hour <= 21; hour++)
                            DropdownMenuItem(value: hour, child: Text('$hour:00')),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => selectedHour = value ?? 18),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Maksimalan broj učesnika',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final capacity = int.tryParse(v ?? '');
                      if (capacity == null || capacity < 1) {
                        return 'Unesite kapacitet, npr. 30';
                      }
                      return null;
                    },
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
                if (selectedDate == null) {
                  setDialogState(() => serverError = 'Odaberite datum seminara.');
                  return;
                }
                final scheduledAt = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedHour,
                );
                final body = {
                  'topic': topicController.text.trim(),
                  'speaker': speakerController.text.trim(),
                  'scheduledAt': scheduledAt.toIso8601String(),
                  'maxCapacity': int.parse(capacityController.text),
                };
                try {
                  final provider = context.read<SeminarsProvider>();
                  if (existing == null) {
                    await provider.insert(body);
                  } else {
                    await provider.update(existing.id, body);
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? 'Seminar je dodan.'
                      : 'Seminar je izmijenjen.');
                } on ApiException catch (e) {
                  setDialogState(() => serverError = e.message);
                }
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRegistrations(Seminar seminar) async {
    final registrations =
        await context.read<SeminarsProvider>().loadRegistrations(seminar.id);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('Učesnici - ${seminar.topic}')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: registrations.isEmpty
              ? const Text('Još nema prijavljenih učesnika.')
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Član')),
                      DataColumn(label: Text('Prijavljen')),
                    ],
                    rows: [
                      for (final registration in registrations)
                        DataRow(cells: [
                          DataCell(Text(
                              '${registration.userFullName} (${registration.username})')),
                          DataCell(
                              Text(Formatters.dateTime(registration.registeredAt))),
                        ]),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _delete(Seminar seminar) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje seminara',
      message: 'Obrisati seminar "${seminar.topic}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<SeminarsProvider>().delete(seminar.id);
      _showSuccess('Seminar je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeminarsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga (tema, predavač)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novi seminar'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.seminars.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema seminara za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Tema')),
                              DataColumn(label: Text('Predavač')),
                              DataColumn(label: Text('Termin')),
                              DataColumn(label: Text('Prijavljeni')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final seminar in provider.seminars)
                                DataRow(cells: [
                                  DataCell(SizedBox(
                                    width: 280,
                                    child: Text(seminar.topic,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2),
                                  )),
                                  DataCell(Text(seminar.speaker)),
                                  DataCell(
                                      Text(Formatters.dateTime(seminar.scheduledAt))),
                                  DataCell(Text(
                                      '${seminar.registeredCount}/${seminar.maxCapacity}')),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Učesnici',
                                      icon: const Icon(Icons.group_outlined),
                                      onPressed: () => _showRegistrations(seminar),
                                    ),
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openForm(existing: seminar),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(seminar),
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
