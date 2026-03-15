import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/audit_log_response.dart';
import 'audit_log_detail_modal.dart';

class AuditLogsTable extends StatefulWidget {
  final List<AuditLogResponse> logs;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final String? selectedEntityType;
  final ValueChanged<String?> onEntityTypeFilterChanged;

  const AuditLogsTable({
    super.key,
    required this.logs,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.selectedEntityType,
    required this.onEntityTypeFilterChanged,
  });

  @override
  State<AuditLogsTable> createState() => _AuditLogsTableState();
}

class _AuditLogsTableState extends State<AuditLogsTable> {
  int? _hoveredRow;

  static const _entityTypes = [
    'User',
    'Staff',
    'Product',
    'ProductCategory',
    'Supplier',
    'MembershipPackage',
    'UserMembership',
    'Order',
    'Appointment',
    'Review',
  ];

  String _entityTypeLabel(String type) {
    switch (type) {
      case 'User':
        return 'Korisnik';
      case 'Staff':
        return 'Osoblje';
      case 'Product':
        return 'Proizvod';
      case 'ProductCategory':
        return 'Kategorija';
      case 'Supplier':
        return 'Dobavljac';
      case 'MembershipPackage':
        return 'Paket clanarine';
      case 'UserMembership':
        return 'Clanarina';
      case 'Order':
        return 'Narudzba';
      case 'Appointment':
        return 'Termin';
      case 'Review':
        return 'Recenzija';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}. '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openDetail(AuditLogResponse log) {
    showDialog(
      context: context,
      builder: (_) => AuditLogDetailModal(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Entity type filter chips
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Sve',
                  isSelected: widget.selectedEntityType == null,
                  onTap: () => widget.onEntityTypeFilterChanged(null),
                ),
                const SizedBox(width: 8),
                ..._entityTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: _entityTypeLabel(type),
                        isSelected: widget.selectedEntityType == type,
                        onTap: () => widget.onEntityTypeFilterChanged(type),
                      ),
                    )),
              ],
            ),
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
                    _HeaderCell('TIP ENTITETA', flex: 2),
                    _HeaderCell('ID', width: 70),
                    _HeaderCell('ADMIN', flex: 2),
                    _HeaderCell('DATUM', flex: 2),
                    _HeaderCell('STATUS', flex: 1),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Nema zapisa u evidenciji',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                )
              else
                ...widget.logs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final log = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
                    child: GestureDetector(
                      onTap: () => _openDetail(log),
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
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    _entityTypeIcon(log.entityType),
                                    color: AppColors.textSecondary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _entityTypeLabel(log.entityType),
                                    style: AppTextStyles.body
                                        .copyWith(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: Text(
                                '#${log.entityId}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                log.adminUsername,
                                style:
                                    AppTextStyles.body.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDate(log.createdAt),
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
                                      color: log.canUndo
                                          ? AppColors.warning
                                              .withValues(alpha: 0.12)
                                          : AppColors.textSecondary
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      log.canUndo ? 'Moze se vratiti' : 'Isteklo',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: log.canUndo
                                            ? AppColors.warning
                                            : AppColors.textSecondary,
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
                                  onPressed: () => _openDetail(log),
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

  IconData _entityTypeIcon(String type) {
    switch (type) {
      case 'User':
        return Icons.person_outlined;
      case 'Staff':
        return Icons.badge_outlined;
      case 'Product':
        return Icons.inventory_2_outlined;
      case 'ProductCategory':
        return Icons.category_outlined;
      case 'Supplier':
        return Icons.local_shipping_outlined;
      case 'MembershipPackage':
        return Icons.card_membership_outlined;
      case 'UserMembership':
        return Icons.card_membership_outlined;
      case 'Order':
        return Icons.shopping_bag_outlined;
      case 'Appointment':
        return Icons.calendar_today_outlined;
      case 'Review':
        return Icons.star_outline;
      default:
        return Icons.delete_outline;
    }
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
