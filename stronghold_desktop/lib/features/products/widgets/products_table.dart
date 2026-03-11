import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/product_response.dart';

class ProductsTable extends StatefulWidget {
  final List<ProductResponse> products;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ProductResponse>? onEdit;
  final ValueChanged<ProductResponse>? onDelete;

  const ProductsTable({
    super.key,
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
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
                    _HeaderCell('ID', width: 50),
                    const SizedBox(width: 44), // Image
                    _HeaderCell('Naziv', flex: 2),
                    _HeaderCell('Kategorija', flex: 1),
                    _HeaderCell('Dobavljac', flex: 1),
                    _HeaderCell('Cijena', width: 80),
                    _HeaderCell('Stanje', width: 70),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Nema proizvoda',
                        style: AppTextStyles.bodySmall),
                  ),
                )
              else
                ...widget.products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                            width: 50,
                            child: Text(
                              '#${product.id}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13, color: AppColors.primary),
                            ),
                          ),

                          // Product image
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _ProductImage(product: product),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              product.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              product.categoryName,
                              style:
                                  AppTextStyles.body.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              product.supplierName,
                              style:
                                  AppTextStyles.body.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '${product.price.toStringAsFixed(2)} KM',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _stockColor(product.stockQuantity)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${product.stockQuantity}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color:
                                      _stockColor(product.stockQuantity),
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
                                  onPressed: () =>
                                      widget.onEdit?.call(product),
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
                                      widget.onDelete?.call(product),
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

  Color _stockColor(int stock) {
    if (stock == 0) return AppColors.error;
    if (stock <= 5) return Colors.orange;
    return AppColors.success;
  }
}

class _ProductImage extends StatelessWidget {
  final ProductResponse product;

  const _ProductImage({required this.product});

  String get _imageUrl {
    final base = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$base${product.imageUrl}';
  }

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.inventory_2_outlined,
            color: AppColors.primary, size: 16),
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
