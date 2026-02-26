import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/date_format_utils.dart';

class OrderHistoryCard extends StatelessWidget {
  final UserOrderResponse order;
  final bool isExpanded;
  final VoidCallback onToggle;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  Color _statusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'processing':
        return AppColors.warning;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = order.orderItems
        .fold<int>(0, (sum, item) => sum + item.quantity);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      'Narudzba ${formatDateDDMMYYYY(order.purchaseDate)}',
                      style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusPill(
                    label: order.statusNameBosnian,
                    color: _statusColor(order.statusName),
                  ),
                ]),
                const SizedBox(height: AppSpacing.md),
                Text('${order.totalAmount.toStringAsFixed(2)} KM',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.navyBlue)),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Datum narudzbe',
                            style: AppTextStyles.caption.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(formatDateDDMMYYYY(order.purchaseDate),
                            style: AppTextStyles.bodyMd.copyWith(color: Colors.white)),
                      ],
                    ),
                    Row(children: [
                      Text(
                          '$totalQty artikl${totalQty == 1 ? '' : 'a'}',
                          style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        isExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        color: Colors.white,
                        size: 18,
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && order.orderItems.isNotEmpty)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: order.orderItems
                  .map((item) => _itemRow(item))
                  .toList(),
            ),
          ),
      ]),
    );
  }

  Widget _itemRow(UserOrderItemResponse item) {
    return Container(
      padding: AppSpacing.listItemPadding,
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.supplementName,
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(
                  '${item.quantity} x ${item.unitPrice.toStringAsFixed(2)} KM',
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
            ],
          ),
        ),
        Text('${item.totalPrice.toStringAsFixed(2)} KM',
            style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
      ]),
    );
  }
}
