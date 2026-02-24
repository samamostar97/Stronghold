import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'glass_card.dart';
import 'section_header.dart';

class WeeklyActivityChart extends StatelessWidget {
  final List<WeeklyVisitResponse> visits;
  final Animation<double> animation;

  const WeeklyActivityChart({
    super.key,
    required this.visits,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final maxMinutes =
        visits.map((v) => v.minutes).fold(0, (a, b) => a > b ? a : b);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Aktivnost proteklih 7 dana'),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: visits.map((visit) {
                final factor =
                    maxMinutes > 0 ? visit.minutes / maxMinutes : 0.0;
                return _dayBar(visit.dayName, factor, visit.minutes);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayBar(String day, double factor, int minutes) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(children: [
          SizedBox(
            height: 18,
            child: minutes > 0
                ? Text('${minutes}m', style: AppTextStyles.caption)
                : null,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor:
                    (factor * animation.value).clamp(0.04, 1.0),
                child: Container(
                  width: 32,
                  decoration: BoxDecoration(
                    gradient: minutes > 0
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : null,
                    color: minutes == 0 ? AppColors.surface : null,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(day,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              )),
        ]);
      },
    );
  }
}
