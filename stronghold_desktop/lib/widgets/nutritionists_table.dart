import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'avatar_widget.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';

class NutritionistsTable extends StatelessWidget {
  const NutritionistsTable({
    super.key,
    required this.nutritionists,
    required this.onEdit,
    required this.onDelete,
  });

  final List<NutritionistResponse> nutritionists;
  final ValueChanged<NutritionistResponse> onEdit;
  final ValueChanged<NutritionistResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: '', flex: 1),
          TableHeaderCell(text: 'Ime i prezime', flex: 3),
          TableHeaderCell(text: 'Email', flex: 3),
          TableHeaderCell(text: 'Telefon', flex: 2),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: nutritionists.length,
      itemBuilder: (context, i) {
        final n = nutritionists[i];
        final initials = _initials(n.firstName, n.lastName);
        return HoverableTableRow(
          index: i,
          isLast: i == nutritionists.length - 1,
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AvatarWidget(initials: initials, size: 32),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(n.fullName,
                  style: AppTextStyles.bodyBold,
                  overflow: TextOverflow.ellipsis),
            ),
            TableDataCell(text: n.email, flex: 3, muted: true),
            TableDataCell(text: n.phoneNumber, flex: 2, muted: true),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni', color: AppColors.secondary, onTap: () => onEdit(n)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi', color: AppColors.error, onTap: () => onDelete(n)),
            ]),
          ]),
        );
      },
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}
