import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/staff_response.dart';

class StaffTable extends StatefulWidget {
  final List<StaffResponse> staff;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final bool showTypeFilter;
  final String? selectedType;
  final ValueChanged<String?>? onTypeFilterChanged;
  final ValueChanged<StaffResponse>? onEdit;
  final ValueChanged<StaffResponse>? onDelete;

  const StaffTable({
    super.key,
    required this.staff,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showTypeFilter = false,
    this.selectedType,
    this.onTypeFilterChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<StaffTable> createState() => _StaffTableState();
}

class _StaffTableState extends State<StaffTable> {
  int? _hoveredRow;

  String _staffTypeLabel(String type) {
    switch (type) {
      case 'Trainer':
        return 'Trener';
      case 'Nutritionist':
        return 'Nutricionist';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Type filter chips
        if (widget.showTypeFilter)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Sve',
                  isSelected: widget.selectedType == null,
                  onTap: () => widget.onTypeFilterChanged?.call(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Treneri',
                  isSelected: widget.selectedType == 'Trainer',
                  onTap: () => widget.onTypeFilterChanged?.call('Trainer'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Nutricionisti',
                  isSelected: widget.selectedType == 'Nutritionist',
                  onTap: () => widget.onTypeFilterChanged?.call('Nutritionist'),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _HeaderCell('ID', width: 60),
                    _HeaderCell('Ime i prezime', flex: 2),
                    _HeaderCell('Email', flex: 2),
                    _HeaderCell('Telefon', flex: 1),
                    _HeaderCell('Tip', flex: 1),
                    _HeaderCell('Status', width: 90),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.staff.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Nema osoblja',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                )
              else
                ...widget.staff.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: open staff detail modal
                      },
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
                              width: 60,
                              child: Text(
                                '#${member.id}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${member.firstName[0]}${member.lastName[0]}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${member.firstName} ${member.lastName}',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                member.email,
                                style: AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                member.phone ?? '-',
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _staffTypeLabel(member.staffType),
                                style: AppTextStyles.body.copyWith(fontSize: 13),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (member.isActive
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  member.isActive ? 'Aktivan' : 'Neaktivan',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: member.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => widget.onEdit?.call(member),
                                    icon: const Icon(Icons.edit_outlined,
                                        color: AppColors.textSecondary, size: 16),
                                    tooltip: 'Uredi',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                  ),
                                  IconButton(
                                    onPressed: () => widget.onDelete?.call(member),
                                    icon: Icon(Icons.delete_outlined,
                                        color: AppColors.error.withValues(alpha: 0.7),
                                        size: 16),
                                    tooltip: 'Obrisi',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
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
                      ? () => widget.onPageChanged(widget.currentPage + 1)
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
