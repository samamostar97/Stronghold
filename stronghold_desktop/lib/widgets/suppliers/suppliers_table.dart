import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class SuppliersTable extends StatelessWidget {
  const SuppliersTable({
    super.key,
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplierResponse> suppliers;
  final ValueChanged<SupplierResponse> onEdit;
  final ValueChanged<SupplierResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Naziv', flex: 3),
          TableHeaderCell(text: 'Web stranica', flex: 3),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, i) {
        final s = suppliers[i];
        return HoverableTableRow(
          index: i,
          isLast: i == suppliers.length - 1,
          child: Row(children: [
            TableDataCell(text: s.name, flex: 3, bold: true),
            TableDataCell(text: s.website ?? '-', flex: 3, muted: true),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni', color: AppColors.secondary, onTap: () => onEdit(s)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi', color: AppColors.error, onTap: () => onDelete(s)),
            ]),
          ]),
        );
      },
    );
  }
}
