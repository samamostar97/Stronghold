import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

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
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    v.durationFormatted,
                    style: const TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
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
