import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class SupplementsTable extends StatelessWidget {
  const SupplementsTable({
    super.key,
    required this.supplements,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplementResponse> supplements;
  final ValueChanged<SupplementResponse> onEdit;
  final ValueChanged<SupplementResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Slika', flex: 1),
          TableHeaderCell(text: 'Naziv', flex: 2),
          TableHeaderCell(text: 'Cijena', flex: 1),
          TableHeaderCell(text: 'Kategorija', flex: 2),
          TableHeaderCell(text: 'Dobavljac', flex: 2),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: supplements.length,
      itemBuilder: (context, i) {
        final s = supplements[i];
        return HoverableTableRow(
          index: i,
          isLast: i == supplements.length - 1,
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _SupplementImage(imageUrl: s.imageUrl),
              ),
            ),
            TableDataCell(text: s.name, flex: 2, bold: true),
            TableDataCell(
                text: '${s.price.toStringAsFixed(2)} KM', flex: 1),
            TableDataCell(
                text: s.supplementCategoryName ?? '-',
                flex: 2,
                muted: true),
            TableDataCell(
                text: s.supplierName ?? '-', flex: 2, muted: true),
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

class _SupplementImage extends StatelessWidget {
  const _SupplementImage({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                '${ApiConfig.baseUrl}$imageUrl',
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Icon(
                    LucideIcons.image,
                    color: AppColors.textMuted,
                    size: 20),
              ),
            )
          : Icon(LucideIcons.image, color: AppColors.textMuted, size: 20),
    );
  }
}
