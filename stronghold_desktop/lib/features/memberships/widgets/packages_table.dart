import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/membership_package_response.dart';

class PackagesTable extends StatefulWidget {
  final List<MembershipPackageResponse> packages;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<MembershipPackageResponse>? onEdit;
  final ValueChanged<MembershipPackageResponse>? onDelete;

  const PackagesTable({
    super.key,
    required this.packages,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PackagesTable> createState() => _PackagesTableState();
}

class _PackagesTableState extends State<PackagesTable> {
  int? _hoveredRow;

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
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _HeaderCell('ID', width: 60),
                    _HeaderCell('Naziv', flex: 2),
                    _HeaderCell('Opis', flex: 3),
                    _HeaderCell('Cijena', flex: 1),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              if (widget.packages.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child:
                        Text('Nema paketa', style: AppTextStyles.bodySmall),
                  ),
                )
              else
                ...widget.packages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pkg = entry.value;
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
                              '#${pkg.id}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              pkg.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              pkg.description ?? '-',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${pkg.price.toStringAsFixed(2)} KM',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      widget.onEdit?.call(pkg),
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppColors.textSecondary,
                                      size: 16),
                                  tooltip: 'Uredi',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.onDelete?.call(pkg),
                                  icon: Icon(Icons.delete_outlined,
                                      color: AppColors.error
                                          .withValues(alpha: 0.7),
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
    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex ?? 1, child: child);
  }
}
