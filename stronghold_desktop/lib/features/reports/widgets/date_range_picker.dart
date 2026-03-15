import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ReportDateRangePicker extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final ValueChanged<DateTime> onFromChanged;
  final ValueChanged<DateTime> onToChanged;

  const ReportDateRangePicker({
    super.key,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }

  Future<void> _pickDate(
      BuildContext context, DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.sidebar,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DateButton(
          label: 'Od',
          value: _formatDate(from),
          onTap: () => _pickDate(context, from, onFromChanged),
        ),
        const SizedBox(width: 12),
        _DateButton(
          label: 'Do',
          value: _formatDate(to),
          onTap: () => _pickDate(context, to, onToChanged),
        ),
      ],
    );
  }
}

class _DateButton extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_DateButton> createState() => _DateButtonState();
}

class _DateButtonState extends State<_DateButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering
                ? Colors.white.withValues(alpha: 0.04)
                : AppColors.sidebar,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.label}: ',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
              ),
              Text(
                widget.value,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
