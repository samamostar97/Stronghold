import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class FaqTable extends StatelessWidget {
  const FaqTable({
    super.key,
    required this.faqs,
    required this.onEdit,
    required this.onDelete,
  });

  final List<FaqResponse> faqs;
  final ValueChanged<FaqResponse> onEdit;
  final ValueChanged<FaqResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Pitanje', flex: 4),
          TableHeaderCell(text: 'Odgovor', flex: 5),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: faqs.length,
      itemBuilder: (context, i) {
        final f = faqs[i];
        return HoverableTableRow(
          index: i,
          isLast: i == faqs.length - 1,
          child: Row(children: [
            Expanded(
              flex: 4,
              child: Tooltip(
                message: f.question,
                child: Text(f.question,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis, maxLines: 2),
              ),
            ),
            Expanded(
              flex: 5,
              child: Tooltip(
                message: f.answer,
                child: Text(f.answer,
                    style: AppTextStyles.bodyMd,
                    overflow: TextOverflow.ellipsis, maxLines: 2),
              ),
            ),
            TableActionCell(flex: 2, children: [
              SmallButton(
                  text: 'Izmijeni', color: AppColors.secondary, onTap: () => onEdit(f)),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi', color: AppColors.error, onTap: () => onDelete(f)),
            ]),
          ]),
        );
      },
    );
  }
}
