import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';
import 'status_pill.dart';

class MembershipPackagesTable extends StatelessWidget {
  const MembershipPackagesTable({
    super.key,
    required this.packages,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MembershipPackageResponse> packages;
  final ValueChanged<MembershipPackageResponse> onEdit;
  final ValueChanged<MembershipPackageResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Naziv paketa', flex: 3),
          TableHeaderCell(text: 'Cijena', flex: 2),
          TableHeaderCell(text: 'Opis', flex: 4),
          TableHeaderCell(text: 'Status', flex: 1),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: packages.length,
      itemBuilder: (context, i) {
        final p = packages[i];
        return HoverableTableRow(
          index: i,
          isLast: i == packages.length - 1,
          child: Row(children: [
            TableDataCell(
                text: p.packageName ?? '-', flex: 3, bold: true),
            TableDataCell(
                text: '${p.packagePrice.toStringAsFixed(2)} KM', flex: 2),
            TableDataCell(
                text: (p.description?.isEmpty ?? true) ? '-' : p.description!,
                flex: 4, muted: true),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: p.isActive ? StatusPill.active() : StatusPill.inactive(),
              ),
            ),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni', color: AppColors.secondary, onTap: () => onEdit(p)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi', color: AppColors.error, onTap: () => onDelete(p)),
            ]),
          ]),
        );
      },
    );
  }
}
