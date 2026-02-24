import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/date_format_utils.dart';
import 'glass_card.dart';
import 'status_pill.dart';

class MembershipPaymentCard extends StatelessWidget {
  final MembershipPaymentResponse payment;

  const MembershipPaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(payment.packageName,
                  style: AppTextStyles.headingSm,
                  overflow: TextOverflow.ellipsis),
            ),
            StatusPill(
              label: payment.isActive ? 'Aktivna' : 'Istekla',
              color:
                  payment.isActive ? AppColors.success : AppColors.error,
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('${payment.amountPaid.toStringAsFixed(2)} KM',
              style: AppTextStyles.bodyBold
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datum uplate', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(formatDateDDMMYYYY(payment.paymentDate),
                      style: AppTextStyles.bodyMd),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Period clanarine',
                      style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${formatDateDDMMYYYY(payment.startDate)} - ${formatDateDDMMYYYY(payment.endDate)}',
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
