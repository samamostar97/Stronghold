import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';

class SeminarsTable extends StatelessWidget {
  const SeminarsTable({
    super.key,
    required this.seminars,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SeminarResponse> seminars;
  final ValueChanged<SeminarResponse> onEdit;
  final ValueChanged<SeminarResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Naziv teme', flex: 3),
          TableHeaderCell(text: 'Voditelj', flex: 2),
          TableHeaderCell(text: 'Datum seminara', flex: 2),
          TableHeaderCell(text: 'Satnica', flex: 1),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: seminars.length,
      itemBuilder: (context, i) {
        final s = seminars[i];
        return HoverableTableRow(
          index: i,
          isLast: i == seminars.length - 1,
          child: Row(children: [
            TableDataCell(text: s.topic, flex: 3, bold: true),
            TableDataCell(text: s.speakerName, flex: 2),
            TableDataCell(
                text: DateFormat('dd.MM.yyyy').format(s.eventDate), flex: 2),
            TableDataCell(
                text: DateFormat('HH:mm').format(s.eventDate), flex: 1),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni',
                  color: AppColors.secondary,
                  onTap: () => onEdit(s)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi',
                  color: AppColors.error,
                  onTap: () => onDelete(s)),
            ]),
          ]),
        );
      },
    );
  }
}
