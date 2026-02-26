import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Hero gradient header for the dashboard with greeting and date.
class DashboardHeroHeader extends StatelessWidget {
  const DashboardHeroHeader({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dobro jutro';
    if (hour < 18) return 'Dobar dan';
    return 'Dobro vece';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd. MMMM yyyy', 'bs')
        .format(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepBlue.withValues(alpha: 0.65),
            AppColors.midBlue.withValues(alpha: 0.55),
            AppColors.navyBlue.withValues(alpha: 0.50),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: AppSpacing.heroRadius,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: _circles(),
          ),
          // Cyan orb
          Positioned(
            bottom: -40,
            right: 60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting, Admin', style: AppTextStyles.heroTitle)
                  .animate()
                  .fadeIn(duration: Motion.dramatic, curve: Motion.curve)
                  .slideY(begin: 0.1, end: 0, duration: Motion.dramatic),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dateStr,
                style: AppTextStyles.bodySecondary
                    .copyWith(color: Colors.white.withOpacity(0.6)),
              )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circles() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(children: [
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.06), width: 1),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.04), width: 1),
            ),
          ),
        ),
      ]),
    );
  }
}
