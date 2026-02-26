import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class CheckoutSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const CheckoutSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTextStyles.bodyBold : AppTextStyles.bodyMd)
              .copyWith(color: Colors.white),
        ),
        Text(
          value,
          style: (isBold ? AppTextStyles.bodyBold : AppTextStyles.bodyMd)
              .copyWith(color: valueColor ?? Colors.white),
        ),
      ],
    );
  }
}
