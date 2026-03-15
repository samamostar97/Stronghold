import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/order_response.dart';
import '../providers/orders_provider.dart';

class OrderDetailModal extends ConsumerStatefulWidget {
  final OrderResponse order;

  const OrderDetailModal({super.key, required this.order});

  @override
  ConsumerState<OrderDetailModal> createState() => _OrderDetailModalState();
}

class _OrderDetailModalState extends ConsumerState<OrderDetailModal> {
  bool _loading = false;

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Na cekanju';
      case 'Confirmed':
        return 'Potvrdjeno';
      case 'Shipped':
        return 'Poslano';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Confirmed':
        return AppColors.info;
      case 'Shipped':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _confirmOrder() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      await repo.confirmOrder(widget.order.id);
      ref.invalidate(ordersProvider);
      ref.invalidate(orderHistoryProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Narudzba #${widget.order.id} je potvrdjenja.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shipOrder() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      await repo.shipOrder(widget.order.id);
      ref.invalidate(ordersProvider);
      ref.invalidate(orderHistoryProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Narudzba #${widget.order.id} je poslana na dostavu.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order.status;

    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Narudzba #${order.id}',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 20),

              // Info
              _InfoRow(label: 'Korisnik', value: order.userName),
              const SizedBox(height: 10),
              _InfoRow(label: 'Adresa dostave', value: order.deliveryAddress),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Datum',
                value: '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}. '
                    '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Ukupno',
                value: '${order.totalAmount.toStringAsFixed(2)} KM',
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              const SizedBox(height: 16),

              // Items header
              Text('Stavke', style: AppTextStyles.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 12),

              // Items list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => Divider(
                    color: Colors.white.withValues(alpha: 0.04),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.quantity}x ${item.unitPrice.toStringAsFixed(2)} KM',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.subtotal.toStringAsFixed(2)} KM',
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action button
              if (status == 'Pending' || status == 'Confirmed') ...[
                const SizedBox(height: 20),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : status == 'Pending'
                            ? _confirmOrder
                            : _shipOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'Pending'
                          ? AppColors.info
                          : AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            status == 'Pending'
                                ? 'Potvrdi narudzbu'
                                : 'Posalji na dostavu',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
