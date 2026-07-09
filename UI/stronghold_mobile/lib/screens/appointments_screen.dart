import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../providers/appointments_provider.dart';
import '../utils/api_client.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
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

  StatusTone _statusTone(String status) => switch (status) {
        'Confirmed' => StatusTone.success,
        'Completed' => StatusTone.neutral,
        'Cancelled' => StatusTone.danger,
        _ => StatusTone.warning,
      };

  /// Otkaz najkasnije 2h prije pocetka - isto pravilo provjerava i backend.
  bool _canCancel(Appointment appointment) {
    if (appointment.status != 'Pending' && appointment.status != 'Confirmed') {
      return false;
    }
    final slotTime = DateTime.utc(appointment.date.year, appointment.date.month,
        appointment.date.day, appointment.startHour);
    return slotTime.isAfter(DateTime.now().toUtc().add(const Duration(hours: 2)));
  }

  Future<void> _cancel(Appointment appointment) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String? serverError;
    bool submitting = false;

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
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        submitting = true;
                        serverError = null;
                      });
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
                        if (dialogContext.mounted) {
                          setDialogState(() {
                            serverError = e.message;
                            submitting = false;
                          });
                        }
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Otkaži termin'),
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
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.navyTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              appointment.staffType == 'Trainer'
                                  ? Icons.fitness_center
                                  : Icons.restaurant_menu,
                              size: 22,
                              color: AppTheme.navy,
                            ),
                          ),
                          title: Text(
                            appointment.staffFullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${Formatters.date(appointment.date)} u ${appointment.startHour}:00',
                              ),
                              const SizedBox(height: 4),
                              StatusChip(
                                label: Formatters.appointmentStatus(
                                    appointment.status),
                                tone: _statusTone(appointment.status),
                              ),
                              if (appointment.cancellationReason != null) ...[
                                const SizedBox(height: 4),
                                Text('Razlog: ${appointment.cancellationReason}'),
                              ],
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
