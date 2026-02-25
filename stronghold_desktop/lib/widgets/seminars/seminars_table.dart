import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class SeminarsTable extends StatelessWidget {
  const SeminarsTable({
    super.key,
    required this.seminars,
    required this.onViewDetails,
    required this.onDelete,
  });

  final List<SeminarResponse> seminars;
  final ValueChanged<SeminarResponse> onViewDetails;
  final ValueChanged<SeminarResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(
          children: [
            TableHeaderCell(text: 'Naziv teme', flex: 3),
            TableHeaderCell(text: 'Voditelj', flex: 2),
            TableHeaderCell(text: 'Popunjenost', flex: 2),
            TableHeaderCell(text: 'Datum', flex: 2),
            TableHeaderCell(text: 'Satnica', flex: 1),
            TableHeaderCell(text: 'Status', flex: 2),
            TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
          ],
        ),
      ),
      itemCount: seminars.length,
      itemBuilder: (context, i) {
        final s = seminars[i];
        return HoverableTableRow(
          index: i,
          isLast: i == seminars.length - 1,
          child: Row(
            children: [
              TableDataCell(text: s.topic, flex: 3, bold: true),
              TableDataCell(text: s.speakerName, flex: 2),
              Expanded(
                flex: 2,
                child: _CapacityIndicator(
                  current: s.currentAttendees,
                  max: s.maxCapacity,
                ),
              ),
              TableDataCell(
                text: DateFormat('dd.MM.yyyy').format(s.eventDate),
                flex: 2,
              ),
              TableDataCell(
                text: DateFormat('HH:mm').format(s.eventDate),
                flex: 1,
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: switch (s.status.toLowerCase()) {
                    'cancelled' => const StatusPill(
                      label: 'Otkazan',
                      color: AppColors.error,
                    ),
                    'finished' => const StatusPill(
                      label: 'Zavrsen',
                      color: AppColors.textMuted,
                    ),
                    _ => const StatusPill(
                      label: 'Aktivan',
                      color: AppColors.success,
                    ),
                  },
                ),
              ),
              TableActionCell(
                flex: 2,
                children: [
                  SmallButton(
                    text: 'Detalji',
                    color: AppColors.primary,
                    onTap: () => onViewDetails(s),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SmallButton(
                    text: 'Obrisi',
                    color: AppColors.error,
                    onTap: () => onDelete(s),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CapacityIndicator extends StatelessWidget {
  const _CapacityIndicator({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isFull = current >= max;
    final color = isFull
        ? AppColors.error
        : ratio > 0.8
        ? AppColors.warning
        : AppColors.success;

    return Text(
      '$current/$max',
      style: AppTextStyles.bodySm.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
