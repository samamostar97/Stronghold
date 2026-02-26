import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Row of 4 stat cards with rich content.
class DashboardStatCards extends StatelessWidget {
  const DashboardStatCards({
    super.key,
    required this.report,
    required this.visitorCount,
    this.heatmap = const [],
  });

  final BusinessReportDTO? report;
  final int visitorCount;
  final List<HeatmapCellDTO> heatmap;

  @override
  Widget build(BuildContext context) {
    final r = report;

    final cards = <Widget>[
      // 1. U TERETANI
      _StatCardShell(
        color: AppColors.cyan,
        icon: LucideIcons.users,
        child: _CardContent(
          label: 'U TERETANI',
          value: '$visitorCount',
          color: AppColors.cyan,
          trailing: _MiniSparkline(
            data: _todayHourlyData(),
            color: AppColors.cyan,
          ),
        ),
      ),

      // 2. PRIHOD (cycles: danas → sedmica → mjesec)
      _RevenueCard(report: r),

      // 3. AKTIVNE CLANARINE
      _StatCardShell(
        color: AppColors.purple,
        icon: LucideIcons.award,
        child: _CardContent(
          label: 'AKTIVNE CLANARINE',
          value: '${r?.activeMemberships ?? 0}',
          color: AppColors.purple,
          warning: (r?.expiringThisWeekCount ?? 0) > 0
              ? '${r!.expiringThisWeekCount} isticu ove sedmice'
              : null,
        ),
      ),

      // 4. CHECK-INI (cycles: danas → sedmica → mjesec)
      _CheckInCard(report: r),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        if (wide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: cards[i]
                        .animate(delay: Duration(milliseconds: 150 + i * 100))
                        .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                  ),
                ],
              ],
            ),
          );
        }
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (int i = 0; i < cards.length; i++)
              SizedBox(
                width: (constraints.maxWidth - AppSpacing.lg) / 2,
                child: cards[i]
                    .animate(delay: Duration(milliseconds: 150 + i * 100))
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve,
                    ),
              ),
          ],
        );
      },
    );
  }

  /// Extract today's hourly visit counts (24 values) from heatmap.
  List<double> _todayHourlyData() {
    if (heatmap.isEmpty) return List.filled(24, 0);
    // .NET DayOfWeek: Sunday=0, Monday=1 ... Saturday=6
    final now = DateTime.now();
    final dotnetDay = now.weekday == 7 ? 0 : now.weekday; // Dart: Mon=1..Sun=7
    final todayCells =
        heatmap.where((c) => c.day == dotnetDay).toList();
    final result = List.filled(24, 0.0);
    for (final c in todayCells) {
      if (c.hour >= 0 && c.hour < 24) result[c.hour] = c.count.toDouble();
    }
    return result;
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// REVENUE CARD (tap to cycle: danas → sedmica → mjesec)
// ─────────────────────────────────────────────────────────────────────────────

enum _RevenuePeriod { danas, sedmica, mjesec }

class _RevenueCard extends StatefulWidget {
  const _RevenueCard({required this.report});
  final BusinessReportDTO? report;

  @override
  State<_RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<_RevenueCard> {
  _RevenuePeriod _period = _RevenuePeriod.mjesec;

  void _cycle() {
    setState(() {
      _period = switch (_period) {
        _RevenuePeriod.danas => _RevenuePeriod.sedmica,
        _RevenuePeriod.sedmica => _RevenuePeriod.mjesec,
        _RevenuePeriod.mjesec => _RevenuePeriod.danas,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final rb = r?.revenueBreakdown;

    final (label, value) = switch (_period) {
      _RevenuePeriod.danas => (
          'PRIHOD (DANAS)',
          '${(rb?.todayRevenue ?? 0).toStringAsFixed(0)} KM',
        ),
      _RevenuePeriod.sedmica => (
          'PRIHOD (SEDMICA)',
          '${(rb?.thisWeekRevenue ?? 0).toStringAsFixed(0)} KM',
        ),
      _RevenuePeriod.mjesec => (
          'PRIHOD (MJESEC)',
          '${(r?.thisMonthRevenue ?? 0).toStringAsFixed(0)} KM',
        ),
    };

    return GestureDetector(
      onTap: _cycle,
      child: _StatCardShell(
        color: AppColors.success,
        icon: LucideIcons.creditCard,
        child: _CardContent(
          label: label,
          value: value,
          color: AppColors.success,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK-IN CARD (tap to cycle: danas → sedmica → mjesec)
// ─────────────────────────────────────────────────────────────────────────────

enum _CheckInPeriod { danas, sedmica, mjesec }

class _CheckInCard extends StatefulWidget {
  const _CheckInCard({required this.report});
  final BusinessReportDTO? report;

  @override
  State<_CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<_CheckInCard> {
  _CheckInPeriod _period = _CheckInPeriod.danas;

  void _cycle() {
    setState(() {
      _period = switch (_period) {
        _CheckInPeriod.danas => _CheckInPeriod.sedmica,
        _CheckInPeriod.sedmica => _CheckInPeriod.mjesec,
        _CheckInPeriod.mjesec => _CheckInPeriod.danas,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;

    final (label, value) = switch (_period) {
      _CheckInPeriod.danas => (
          'CHECK-INI (DANAS)',
          '${r?.todayCheckIns ?? 0}',
        ),
      _CheckInPeriod.sedmica => (
          'CHECK-INI (SEDMICA)',
          '${r?.thisWeekVisits ?? 0}',
        ),
      _CheckInPeriod.mjesec => (
          'CHECK-INI (MJESEC)',
          '${r?.last30DaysCheckIns ?? 0}',
        ),
    };

    return GestureDetector(
      onTap: _cycle,
      child: _StatCardShell(
        color: AppColors.electric,
        icon: LucideIcons.logIn,
        child: _CardContent(
          label: label,
          value: value,
          color: AppColors.electric,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD SHELL (hover, border, shadow)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardShell extends StatefulWidget {
  const _StatCardShell({
    required this.color,
    required this.icon,
    required this.child,
  });

  final Color color;
  final IconData icon;
  final Widget child;

  @override
  State<_StatCardShell> createState() => _StatCardShellState();
}

class _StatCardShellState extends State<_StatCardShell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: AppSpacing.cardPaddingCompact,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: _hover
                ? widget.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow:
              _hover ? AppColors.cardShadowStrong : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: AppSpacing.avatarRadius,
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.label,
    required this.value,
    required this.color,
    this.warning,
    this.trailing,
  });

  final String label;
  final String value;
  final Color color;
  final String? warning;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.overline),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: AppTextStyles.metricMedium),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
        if (warning != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle,
                  size: 12, color: AppColors.orange),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  warning!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.orange, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINI SPARKLINE (CustomPainter)
// ─────────────────────────────────────────────────────────────────────────────

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 28,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final step = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - (data[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
