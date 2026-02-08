import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'status_pill.dart';

class OrderDetailsDialog extends StatelessWidget {
  const OrderDetailsDialog({
    super.key,
    required this.order,
    required this.onMarkDelivered,
  });

  final OrderResponse order;
  final VoidCallback onMarkDelivered;

  String _fmtDate(DateTime dt) => DateFormat('dd.MM.yyyy HH:mm').format(dt);
  String _fmtCurrency(double a) => '${a.toStringAsFixed(2)} KM';

  @override
  Widget build(BuildContext context) {
    final canDeliver = order.status != OrderStatus.delivered;
    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Text('Narudzba #${order.id}',
                    style: AppTextStyles.headingMd),
                const SizedBox(width: AppSpacing.lg),
                order.status == OrderStatus.delivered
                    ? StatusPill.delivered()
                    : StatusPill.pending(),
                const Spacer(),
                IconButton(
                  icon: Icon(LucideIcons.x,
                      color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              _infoCard(),
              const SizedBox(height: AppSpacing.xl),
              Text('Stavke narudzbe', style: AppTextStyles.headingSm),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: _itemsTable()),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Zatvori',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textMuted)),
                  ),
                  if (canDeliver) ...[
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: onMarkDelivered,
                      icon: Icon(LucideIcons.checkCircle, size: 18),
                      label: Text('Oznaci kao dostavljeno',
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.background)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(children: [
          _InfoRow(label: 'Korisnik', value: order.userFullName),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Email', value: order.userEmail),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
              label: 'Datum narudzbe',
              value: _fmtDate(order.purchaseDate)),
          if (order.stripePaymentId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'ID placanja', value: order.stripePaymentId!),
          ],
        ]),
      );

  Widget _itemsTable() => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              Expanded(
                  flex: 4,
                  child: Text('PROIZVOD', style: AppTextStyles.label)),
              Expanded(
                  flex: 1,
                  child: Text('KOL.',
                      style: AppTextStyles.label,
                      textAlign: TextAlign.center)),
              Expanded(
                  flex: 2,
                  child: Text('CIJENA',
                      style: AppTextStyles.label,
                      textAlign: TextAlign.right)),
              Expanded(
                  flex: 2,
                  child: Text('UKUPNO',
                      style: AppTextStyles.label,
                      textAlign: TextAlign.right)),
            ]),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: order.orderItems.length,
              itemBuilder: (_, i) {
                final item = order.orderItems[i];
                final isLast = i == order.orderItems.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(children: [
                    Expanded(
                        flex: 4,
                        child: Text(item.supplementName,
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis)),
                    Expanded(
                        flex: 1,
                        child: Text('${item.quantity}',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 2,
                        child: Text(_fmtCurrency(item.unitPrice),
                            style: AppTextStyles.bodyMd,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text(_fmtCurrency(item.totalPrice),
                            style: AppTextStyles.bodyBold,
                            textAlign: TextAlign.right)),
                  ]),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: AppColors.border, width: 2)),
            ),
            child: Row(children: [
              Expanded(
                  flex: 7,
                  child: Text('Ukupno za platiti',
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 15))),
              Expanded(
                  flex: 2,
                  child: Text(_fmtCurrency(order.totalAmount),
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.primary, fontSize: 16),
                      textAlign: TextAlign.right)),
            ]),
          ),
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: AppTextStyles.bodyMd)),
        Expanded(
          child: Text(value,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
