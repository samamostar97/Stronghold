import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import 'report_export_button.dart';

/// Compact row with export actions.
class ReportDateRangeBar extends StatelessWidget {
  const ReportDateRangeBar({
    super.key,
    required this.onExportExcel,
    required this.onExportPdf,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReportExportButton.excel(onPressed: onExportExcel, label: 'Export u Excel'),
        const SizedBox(width: AppSpacing.md),
        ReportExportButton.pdf(onPressed: onExportPdf, label: 'Export u PDF'),
      ],
    );
  }
}
