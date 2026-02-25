import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class AppointmentsTable extends StatelessWidget {
  const AppointmentsTable({
    super.key,
    required this.appointments,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AdminAppointmentResponse> appointments;
  final ValueChanged<AdminAppointmentResponse> onEdit;
  final ValueChanged<AdminAppointmentResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Korisnik', flex: 3),
          TableHeaderCell(text: 'Tip', flex: 2),
          TableHeaderCell(text: 'Osoblje', flex: 3),
          TableHeaderCell(text: 'Datum', flex: 2),
          TableHeaderCell(text: 'Satnica', flex: 1),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: appointments.length,
      itemBuilder: (context, i) {
        final a = appointments[i];
        final staffName = a.trainerName ?? a.nutritionistName ?? '-';
        final isPast = a.appointmentDate.isBefore(DateTime.now());

        return HoverableTableRow(
          index: i,
          isLast: i == appointments.length - 1,
          child: Row(children: [
            TableDataCell(text: a.userName, flex: 3, bold: true),
            Expanded(
              flex: 2,
              child: _TypeChip(type: a.type),
            ),
            TableDataCell(text: staffName, flex: 3),
            TableDataCell(
              text: DateFormat('dd.MM.yyyy').format(a.appointmentDate),
              flex: 2,
              muted: isPast,
            ),
            TableDataCell(
              text: DateFormat('HH:mm').format(a.appointmentDate),
              flex: 1,
              muted: isPast,
            ),
            TableActionCell(flex: 2, children: [
              SmallButton(
                text: 'Izmijeni',
                color: AppColors.secondary,
                onTap: () => onEdit(a),
              ),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                text: 'Obrisi',
                color: AppColors.error,
                onTap: () => onDelete(a),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final isTrainer = type == 'Trener';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (isTrainer ? AppColors.primary : AppColors.accent)
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isTrainer ? AppColors.primary : AppColors.accent,
          ),
        ),
      ),
    );
  }
}
