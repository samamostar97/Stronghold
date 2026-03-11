import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/appointment_response.dart';
import 'appointment_detail_modal.dart';

class AppointmentsTable extends StatefulWidget {
  final List<AppointmentResponse> appointments;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final bool showStatusFilter;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusFilterChanged;
  final List<String> filterStatuses;

  const AppointmentsTable({
    super.key,
    required this.appointments,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showStatusFilter = false,
    this.selectedStatus,
    this.onStatusFilterChanged,
    this.filterStatuses = const [],
  });

  @override
  State<AppointmentsTable> createState() => _AppointmentsTableState();
}

class _AppointmentsTableState extends State<AppointmentsTable> {
  int? _hoveredRow;

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Na cekanju';
      case 'Approved':
        return 'Odobreno';
      case 'Rejected':
        return 'Odbijeno';
      case 'Completed':
        return 'Zavrseno';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Approved':
        return AppColors.info;
      case 'Rejected':
        return AppColors.error;
      case 'Completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year}. '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openDetail(AppointmentResponse appointment) {
    showDialog(
      context: context,
      builder: (_) => AppointmentDetailModal(appointment: appointment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter chips
        if (widget.showStatusFilter && widget.filterStatuses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Sve',
                  isSelected: widget.selectedStatus == null,
                  onTap: () => widget.onStatusFilterChanged?.call(null),
                ),
                ...widget.filterStatuses.map((status) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: _statusLabel(status),
                        isSelected: widget.selectedStatus == status,
                        onTap: () =>
                            widget.onStatusFilterChanged?.call(status),
                      ),
                    )),
              ],
            ),
          ),

        // Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _HeaderCell('ID', width: 70),
                    _HeaderCell('Korisnik', flex: 2),
                    _HeaderCell('Osoblje', flex: 2),
                    _HeaderCell('Datum/Vrijeme', flex: 2),
                    _HeaderCell('Status', flex: 1),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.appointments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Nema termina',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                )
              else
                ...widget.appointments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final apt = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
                    child: GestureDetector(
                      onTap: () => _openDetail(apt),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                '#${apt.id}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                apt.userName,
                                style:
                                    AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                apt.staffName,
                                style:
                                    AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDateTime(apt.scheduledAt),
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(apt.status)
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _statusLabel(apt.status),
                                      style:
                                          AppTextStyles.bodySmall.copyWith(
                                        color:
                                            _statusColor(apt.status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _openDetail(apt),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: Text(
                                    'Detalji',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
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

        // Pagination
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
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: widget.currentPage > 1
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
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
                        child: Text(
                          '$page',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.currentPage < widget.totalPages
                      ? () =>
                          widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.currentPage < widget.totalPages
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
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
    final child = Text(
      label,
      style: AppTextStyles.label.copyWith(fontSize: 11),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(flex: flex ?? 1, child: child);
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : _hovering
                    ? Colors.white.withValues(alpha: 0.04)
                    : AppColors.sidebar,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight:
                  widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
