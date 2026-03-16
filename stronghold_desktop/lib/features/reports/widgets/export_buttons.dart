import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/reports_provider.dart';

class ExportButtons extends ConsumerStatefulWidget {
  final String endpoint;
  final String fileBaseName;
  final NotifierProvider<dynamic, ReportDateRange> dateRangeProvider;

  const ExportButtons({
    super.key,
    required this.endpoint,
    required this.fileBaseName,
    required this.dateRangeProvider,
  });

  @override
  ConsumerState<ExportButtons> createState() => _ExportButtonsState();
}

class _ExportButtonsState extends ConsumerState<ExportButtons> {
  bool _loadingPdf = false;
  bool _loadingExcel = false;

  Future<void> _export(String format) async {
    final range = ref.read(widget.dateRangeProvider);
    final fromStr =
        '${range.from.year}${range.from.month.toString().padLeft(2, '0')}${range.from.day.toString().padLeft(2, '0')}';
    final toStr =
        '${range.to.year}${range.to.month.toString().padLeft(2, '0')}${range.to.day.toString().padLeft(2, '0')}';
    final ext = format == 'pdf' ? 'pdf' : 'xlsx';
    final defaultName = '${widget.fileBaseName}_${fromStr}_$toStr.$ext';

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Sacuvaj izvjestaj',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: [ext],
    );

    if (path == null) return;

    setState(() {
      if (format == 'pdf') {
        _loadingPdf = true;
      } else {
        _loadingExcel = true;
      }
    });

    try {
      final repo = ref.read(reportsRepositoryProvider);
      final response = await repo.downloadReport(
        endpoint: '/reports/${widget.endpoint}',
        from: range.from,
        to: range.to,
        format: format,
      );

      final file = File(path);
      await file.writeAsBytes(response.data as List<int>);

      if (mounted) {
        AppSnackbar.success(context, 'Izvjestaj sacuvan: ${file.path}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Greska pri exportu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPdf = false;
          _loadingExcel = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(widget.dateRangeProvider);
    final invalidRange = range.to.isBefore(range.from);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExportButton(
          label: 'PDF',
          icon: Icons.picture_as_pdf_outlined,
          loading: _loadingPdf,
          disabled: invalidRange,
          onTap: () => _export('pdf'),
        ),
        const SizedBox(width: 8),
        _ExportButton(
          label: 'Excel',
          icon: Icons.table_chart_outlined,
          loading: _loadingExcel,
          disabled: invalidRange,
          onTap: () => _export('excel'),
        ),
      ],
    );
  }
}

class _ExportButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.loading,
    this.disabled = false,
    required this.onTap,
  });

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.loading;
    final color = isDisabled ? AppColors.textSecondary : AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: isDisabled ? null : widget.onTap,
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: !isDisabled && _hovering
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.sidebar,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: widget.loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
