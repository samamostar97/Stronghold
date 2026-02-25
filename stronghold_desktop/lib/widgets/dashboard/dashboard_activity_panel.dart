import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../shared/horizontal_bar_chart.dart';

/// Gym activity panel showing weekday visits as horizontal bars.
class DashboardActivityPanel extends StatelessWidget {
  const DashboardActivityPanel({super.key, required this.visitsByWeekday});

  final List<WeekdayVisitsDTO> visitsByWeekday;

  static const _dayLabels = ['Pon', 'Uto', 'Sri', 'Cet', 'Pet', 'Sub', 'Ned'];
  static const _backendToDisplay = {1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 0: 6};

  @override
  Widget build(BuildContext context) {
    final data = List.filled(7, 0);
    for (final entry in visitsByWeekday) {
      final idx = _backendToDisplay[entry.day];
      if (idx != null) data[idx] = entry.count;
    }

    final chartData = <({String label, double value})>[
      for (int i = 0; i < 7; i++)
        (label: _dayLabels[i], value: data[i].toDouble()),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sedmicna posjecenost', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xl),
          HorizontalBarChart(data: chartData, accentColor: AppColors.primary),
        ],
      ),
    );
  }
}
