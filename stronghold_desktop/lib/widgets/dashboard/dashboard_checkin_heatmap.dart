import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Weekly check-in heatmap: 7 rows (Mon-Sun) × hours (06-21).
/// Cell color intensity reflects visit count relative to max.
class DashboardCheckinHeatmap extends StatefulWidget {
  const DashboardCheckinHeatmap({super.key, required this.data});

  final List<HeatmapCellDTO> data;

  @override
  State<DashboardCheckinHeatmap> createState() =>
      _DashboardCheckinHeatmapState();
}

class _DashboardCheckinHeatmapState extends State<DashboardCheckinHeatmap> {
  int? _hoverDay;
  int? _hoverHour;

  static const _dayLabels = ['Pon', 'Uto', 'Sri', 'Cet', 'Pet', 'Sub', 'Ned'];

  // .NET DayOfWeek: Sunday=0, Monday=1 ... Saturday=6
  // Display order: Mon(1), Tue(2), Wed(3), Thu(4), Fri(5), Sat(6), Sun(0)
  static const _backendDayOrder = [1, 2, 3, 4, 5, 6, 0];

  // Gym working hours
  static const _startHour = 6;
  static const _endHour = 21;
  static const _hourCount = _endHour - _startHour; // 15 hours

  @override
  Widget build(BuildContext context) {
    // Build 7×15 grid from data (06:00 - 20:59)
    final grid = List.generate(7, (_) => List.filled(_hourCount, 0));
    int maxCount = 0;

    for (final cell in widget.data) {
      final rowIdx = _backendDayOrder.indexOf(cell.day);
      if (rowIdx < 0 || cell.hour < _startHour || cell.hour >= _endHour) continue;
      grid[rowIdx][cell.hour - _startHour] = cell.count;
      if (cell.count > maxCount) maxCount = cell.count;
    }

    const labelWidth = 36.0;
    const cellGap = 2.0;
    const headerHeight = 20.0;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Check-in Heatmap', style: AppTextStyles.headingSm),
              const SizedBox(width: AppSpacing.md),
              Text(
                'ova sedmica',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - labelWidth;
              final cellWidth =
                  (availableWidth - cellGap * (_hourCount - 1)) / _hourCount;
              final cellHeight = cellWidth.clamp(14.0, 22.0);

              return Column(
                children: [
                  // Hour labels
                  Padding(
                    padding: const EdgeInsets.only(left: labelWidth),
                    child: SizedBox(
                      height: headerHeight,
                      child: Row(
                        children: List.generate(_hourCount, (i) {
                          final h = i + _startHour;
                          return SizedBox(
                            width: cellWidth + (i < _hourCount - 1 ? cellGap : 0),
                            child: i % 3 == 0
                                ? Text(
                                    h.toString().padLeft(2, '0'),
                                    style: AppTextStyles.overline.copyWith(
                                      fontSize: 9,
                                      color: AppColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink(),
                          );
                        }),
                      ),
                    ),
                  ),
                  // Grid rows
                  ...List.generate(7, (dayIdx) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: dayIdx < 6 ? cellGap : 0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: labelWidth,
                            height: cellHeight,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _dayLabels[dayIdx],
                                style: AppTextStyles.overline.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(_hourCount, (i) {
                            final h = i + _startHour;
                            final count = grid[dayIdx][i];
                            final intensity = maxCount > 0
                                ? (count / maxCount).clamp(0.0, 1.0)
                                : 0.0;
                            final isHovered =
                                _hoverDay == dayIdx && _hoverHour == i;

                            return Padding(
                              padding: EdgeInsets.only(
                                  right: i < _hourCount - 1 ? cellGap : 0),
                              child: MouseRegion(
                                onEnter: (_) => setState(() {
                                  _hoverDay = dayIdx;
                                  _hoverHour = i;
                                }),
                                onExit: (_) => setState(() {
                                  _hoverDay = null;
                                  _hoverHour = null;
                                }),
                                child: Tooltip(
                                  message:
                                      '${_dayLabels[dayIdx]} ${h.toString().padLeft(2, '0')}:00 — $count posjeta',
                                  waitDuration:
                                      const Duration(milliseconds: 200),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    width: cellWidth,
                                    height: cellHeight,
                                    decoration: BoxDecoration(
                                      color: count == 0
                                          ? AppColors.surfaceAlt
                                          : Color.lerp(
                                              AppColors.cyan
                                                  .withValues(alpha: 0.15),
                                              AppColors.cyan,
                                              intensity,
                                            ),
                                      borderRadius:
                                          BorderRadius.circular(3),
                                      border: isHovered
                                          ? Border.all(
                                              color: AppColors.electric,
                                              width: 1.5,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Legend
          Row(
            children: [
              Text('Manje', style: AppTextStyles.overline.copyWith(fontSize: 9)),
              const SizedBox(width: AppSpacing.xs),
              ...List.generate(5, (i) {
                final t = i / 4;
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.surfaceAlt
                        : Color.lerp(
                            AppColors.cyan.withValues(alpha: 0.15),
                            AppColors.cyan,
                            t,
                          ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: AppSpacing.xs),
              Text('Vise', style: AppTextStyles.overline.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
