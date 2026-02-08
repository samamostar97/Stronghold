import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';

class VisitorsTable extends StatelessWidget {
  const VisitorsTable({
    super.key,
    required this.visitors,
    required this.onCheckOut,
  });

  final List<CurrentVisitorResponse> visitors;
  final ValueChanged<CurrentVisitorResponse> onCheckOut;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Korisnicko ime', flex: 2),
          TableHeaderCell(text: 'Ime i prezime', flex: 3),
          TableHeaderCell(text: 'Vrijeme dolaska', flex: 2),
          TableHeaderCell(text: 'Trajanje', flex: 2),
          TableHeaderCell(text: 'Akcija', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: visitors.length,
      itemBuilder: (context, i) {
        final v = visitors[i];
        return HoverableTableRow(
          index: i,
          isLast: i == visitors.length - 1,
          child: Row(children: [
            TableDataCell(text: v.username, flex: 2),
            TableDataCell(text: v.fullName, flex: 3, bold: true),
            TableDataCell(text: v.checkInTimeFormatted, flex: 2),
            TableDataCell(text: v.durationFormatted, flex: 2),
            TableActionCell(flex: 2, children: [
              SmallButton(
                text: 'Check-out',
                color: AppColors.error,
                onTap: () => onCheckOut(v),
              ),
            ]),
          ]),
        );
      },
    );
  }
}
