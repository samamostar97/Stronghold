import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';

class CategoriesTable extends StatelessWidget {
  const CategoriesTable({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplementCategoryResponse> categories;
  final ValueChanged<SupplementCategoryResponse> onEdit;
  final ValueChanged<SupplementCategoryResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Naziv', flex: 3),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final c = categories[i];
        return HoverableTableRow(
          index: i,
          isLast: i == categories.length - 1,
          child: Row(children: [
            TableDataCell(text: c.name, flex: 3, bold: true),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni', color: AppColors.secondary, onTap: () => onEdit(c)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi', color: AppColors.error, onTap: () => onDelete(c)),
            ]),
          ]),
        );
      },
    );
  }
}
