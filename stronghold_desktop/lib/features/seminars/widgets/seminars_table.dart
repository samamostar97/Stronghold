import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/seminar_response.dart';
import 'seminar_registrations_modal.dart';

class SeminarsTable extends StatefulWidget {
  final List<SeminarResponse> seminars;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<SeminarResponse> onEdit;
  final ValueChanged<SeminarResponse> onDelete;
  final bool showActions;

  const SeminarsTable({
    super.key,
    required this.seminars,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
  });

  @override
  State<SeminarsTable> createState() => _SeminarsTableState();
}

class _SeminarsTableState extends State<SeminarsTable> {
  int? _hoveredRow;

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}. '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(SeminarResponse s) {
    if (s.startDate.isBefore(DateTime.now())) return 'Zavrsen';
    if (s.registeredCount >= s.maxCapacity) return 'Popunjen';
    return 'Aktivan';
  }

  Color _statusColor(SeminarResponse s) {
    if (s.startDate.isBefore(DateTime.now())) return AppColors.textSecondary;
    if (s.registeredCount >= s.maxCapacity) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _HeaderCell('NAZIV', flex: 2),
                    _HeaderCell('PREDAVAC', flex: 2),
                    _HeaderCell('DATUM', flex: 2),
                    _HeaderCell('KAPACITET', flex: 1),
                    _HeaderCell('STATUS', flex: 1),
                    if (widget.showActions) const SizedBox(width: 120),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),
              if (widget.seminars.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                      child: Text('Nema seminara',
                          style: AppTextStyles.bodySmall)),
                )
              else
                ...widget.seminars.asMap().entries.map((entry) {
                  final index = entry.key;
                  final s = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              SeminarRegistrationsModal(seminar: s),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(s.name,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(s.lecturer,
                                  style:
                                      AppTextStyles.body.copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(_formatDate(s.startDate),
                                  style: AppTextStyles.bodySmall
                                      .copyWith(fontSize: 12)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  '${s.registeredCount}/${s.maxCapacity}',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(fontSize: 13)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(s)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _statusLabel(s),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _statusColor(s),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.showActions)
                              SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => widget.onEdit(s),
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18, color: AppColors.primary),
                                      tooltip: 'Uredi',
                                    ),
                                    IconButton(
                                      onPressed: () => widget.onDelete(s),
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18, color: AppColors.error),
                                      tooltip: 'Obrisi',
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        if (widget.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.currentPage > 1
                      ? () => widget.onPageChanged(widget.currentPage - 1)
                      : null,
                  icon: Icon(Icons.chevron_left_rounded,
                      color: widget.currentPage > 1
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: 8),
                ...List.generate(widget.totalPages, (i) {
                  final page = i + 1;
                  final isActive = page == widget.currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () => widget.onPageChanged(page),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('$page',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.currentPage < widget.totalPages
                      ? () => widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  icon: Icon(Icons.chevron_right_rounded,
                      color: widget.currentPage < widget.totalPages
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.3)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  final int? flex;

  const _HeaderCell(this.label, {this.width, this.flex});

  @override
  Widget build(BuildContext context) {
    final child =
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 11));
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }
}
