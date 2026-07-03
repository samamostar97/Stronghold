import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../providers/appointments_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import 'book_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppointmentsProvider>().load(),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'Confirmed' => Colors.green.shade700,
        'Completed' => Colors.blueGrey,
        'Cancelled' => Theme.of(context).colorScheme.error,
        _ => Colors.orange.shade800,
      };

  bool _canCancel(Appointment appointment) {
    if (appointment.status != 'Pending' && appointment.status != 'Confirmed') {
      return false;
    }
    final slotTime = DateTime(appointment.date.year, appointment.date.month,
        appointment.date.day, appointment.startHour);
    return slotTime.isAfter(DateTime.now());
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
                  'Otkazati termin kod ${appointment.staffFullName} '
                  '(${Formatters.date(appointment.date)} u ${appointment.startHour}:00)?',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Razlog otkazivanja',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite razlog otkazivanja.'
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Termin je otkazan.')),
                    );
                  }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Moji termini')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Zakaži termin'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
        ),
      ),
      body: provider.loading && provider.appointments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.appointments.isEmpty
              ? const Center(child: Text('Nemate zakazanih termina.'))
              : RefreshIndicator(
                  onRefresh: () => provider.load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                    itemCount: provider.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = provider.appointments[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            appointment.staffType == 'Trainer'
                                ? Icons.fitness_center
                                : Icons.restaurant_menu,
                          ),
                          title: Text(appointment.staffFullName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${Formatters.date(appointment.date)} u ${appointment.startHour}:00',
                              ),
                              Text(
                                Formatters.appointmentStatus(appointment.status),
                                style: TextStyle(
                                  color: _statusColor(appointment.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (appointment.cancellationReason != null)
                                Text('Razlog: ${appointment.cancellationReason}'),
                            ],
                          ),
                          trailing: _canCancel(appointment)
                              ? TextButton(
                                  onPressed: () => _cancel(appointment),
                                  child: const Text('Otkaži'),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
