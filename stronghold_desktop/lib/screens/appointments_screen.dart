import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/appointments/appointment_add_dialog.dart';
import '../widgets/appointments/appointment_edit_dialog.dart';
import '../widgets/appointments/appointments_table.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/success_animation.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentListProvider.notifier).load();
    });
  }

  Future<void> _addAppointment() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => AppointmentAddDialog(
        onCreate: (request) async {
          await ref.read(appointmentListProvider.notifier).create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editAppointment(AdminAppointmentResponse appointment) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => AppointmentEditDialog(
        appointment: appointment,
        onUpdate: (request) async {
          await ref
              .read(appointmentListProvider.notifier)
              .update(appointment.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteAppointment(AdminAppointmentResponse appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati termin korisnika "${appointment.userName}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(appointmentListProvider.notifier).delete(appointment.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'delete-appointment'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListProvider);
    final notifier = ref.read(appointmentListProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CrudListScaffold<AdminAppointmentResponse,
              AppointmentQueryFilter>(
            state: state,
            onRefresh: notifier.refresh,
            onSearch: notifier.setSearch,
            onSort: notifier.setOrderBy,
            onPageChanged: notifier.goToPage,
            onAdd: _addAppointment,
            searchHint: 'Pretrazi po korisniku, treneru...',
            addButtonText: '+ Dodaj termin',
            loadingColumnFlex: const [3, 2, 3, 2, 1, 2],
            sortOptions: const [
              SortOption(value: null, label: 'Zadano'),
              SortOption(value: 'datedesc', label: 'Najnovije'),
              SortOption(value: 'date', label: 'Najstarije'),
              SortOption(value: 'user', label: 'Korisnik (A-Z)'),
              SortOption(value: 'userdesc', label: 'Korisnik (Z-A)'),
            ],
            tableBuilder: (items) => AppointmentsTable(
              appointments: items,
              onEdit: _editAppointment,
              onDelete: _deleteAppointment,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }
}
