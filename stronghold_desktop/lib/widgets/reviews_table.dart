import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';
import 'star_rating.dart';

class ReviewsTable extends StatelessWidget {
  const ReviewsTable({
    super.key,
    required this.reviews,
    required this.onDelete,
  });

  final List<ReviewResponse> reviews;
  final ValueChanged<ReviewResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Korisnik', flex: 2),
          TableHeaderCell(text: 'Proizvod', flex: 3),
          TableHeaderCell(text: 'Ocjena', flex: 2),
          TableHeaderCell(text: 'Komentar', flex: 4),
          TableHeaderCell(text: 'Akcije', flex: 1, alignRight: true),
        ]),
      ),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final r = reviews[i];
        return HoverableTableRow(
          index: i,
          isLast: i == reviews.length - 1,
          child: Row(children: [
            TableDataCell(text: r.userName ?? '-', flex: 2),
            TableDataCell(text: r.supplementName ?? '-', flex: 3),
            Expanded(
              flex: 2,
              child: StarRating(rating: r.rating),
            ),
            Expanded(
              flex: 4,
              child: Tooltip(
                message: r.comment ?? '',
                child: Text(
                  r.comment ?? '-',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            TableActionCell(flex: 1, children: [
              SmallButton(
                text: 'Obrisi',
                color: AppColors.error,
                onTap: () => onDelete(r),
              ),
            ]),
          ]),
        );
      },
    );
  }
}
