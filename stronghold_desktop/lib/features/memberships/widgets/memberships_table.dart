import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/user_membership_response.dart';

class MembershipsTable extends StatefulWidget {
  final List<UserMembershipResponse> memberships;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final bool showCancelAction;
  final ValueChanged<UserMembershipResponse>? onCancel;
  final bool showStatusFilter;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusFilterChanged;

  const MembershipsTable({
    super.key,
    required this.memberships,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showCancelAction = false,
    this.onCancel,
    this.showStatusFilter = false,
    this.selectedStatus,
    this.onStatusFilterChanged,
  });

  @override
  State<MembershipsTable> createState() => _MembershipsTableState();
}

class _MembershipsTableState extends State<MembershipsTable> {
  int? _hoveredRow;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter chips
        if (widget.showStatusFilter)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Sve',
                  isSelected: widget.selectedStatus == null,
                  onTap: () => widget.onStatusFilterChanged?.call(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Istekle',
                  isSelected: widget.selectedStatus == 'Expired',
                  onTap: () =>
                      widget.onStatusFilterChanged?.call('Expired'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Otkazane',
                  isSelected: widget.selectedStatus == 'Cancelled',
                  onTap: () =>
                      widget.onStatusFilterChanged?.call('Cancelled'),
                ),
              ],
            ),
          ),

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
                    _HeaderCell('ID', width: 60),
                    _HeaderCell('Korisnik', flex: 2),
                    _HeaderCell('Paket', flex: 2),
                    _HeaderCell('Cijena', flex: 1),
                    _HeaderCell('Pocetak', flex: 1),
                    _HeaderCell('Istek', flex: 1),
                    if (!widget.showCancelAction)
                      _HeaderCell('Status', width: 100),
                    if (widget.showCancelAction) const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.memberships.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Nema clanarina',
                        style: AppTextStyles.bodySmall),
                  ),
                )
              else
                ...widget.memberships.asMap().entries.map((entry) {
                  final index = entry.key;
                  final membership = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
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
                          SizedBox(
                            width: 60,
                            child: Text(
                              '#${membership.id}',
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
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      membership.userFullName.isNotEmpty
                                          ? membership.userFullName
                                              .split(' ')
                                              .map((n) => n.isNotEmpty
                                                  ? n[0]
                                                  : '')
                                              .take(2)
                                              .join()
                                          : '?',
                                      style:
                                          AppTextStyles.bodySmall.copyWith(
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
                                    membership.userFullName,
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
                              membership.membershipPackageName,
                              style:
                                  AppTextStyles.body.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${membership.membershipPackagePrice.toStringAsFixed(2)} KM',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _formatDate(membership.startDate),
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _formatDate(membership.endDate),
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                          if (!widget.showCancelAction)
                            SizedBox(
                              width: 100,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (membership.isActive
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  membership.isActive
                                      ? 'Aktivna'
                                      : membership.endDate
                                              .isBefore(DateTime.now())
                                          ? 'Istekla'
                                          : 'Otkazana',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: membership.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.showCancelAction)
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        widget.onCancel?.call(membership),
                                    icon: Icon(Icons.cancel_outlined,
                                        color: AppColors.error
                                            .withValues(alpha: 0.7),
                                        size: 16),
                                    tooltip: 'Ukini clanarinu',
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
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }
}
