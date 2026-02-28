import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Bar chart showing daily gym visits over the last 30 days.
class DashboardVisitsBarChart extends StatefulWidget {
  const DashboardVisitsBarChart({super.key, required this.data});

  final List<DailyVisitsDTO> data;

  @override
  State<DashboardVisitsBarChart> createState() =>
      _DashboardVisitsBarChartState();
}

class _DashboardVisitsBarChartState extends State<DashboardVisitsBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold<int>(0, (s, d) => s + d.visitCount);

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
              Text('Posjete po danima', style: AppTextStyles.headingSm),
              const SizedBox(width: AppSpacing.md),
              Text('zadnjih 30 dana', style: AppTextStyles.caption),
              const Spacer(),
              _Chip(
                label: 'Ukupno',
                value: '$total',
                color: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return MouseRegion(
              onHover: (event) {
                final idx = _hitIndex(
                  event.localPosition,
                  constraints.maxWidth,
                  widget.data.length,
                );
                if (idx != _hoveredIndex) setState(() => _hoveredIndex = idx);
              },
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _VisitsBarPainter(
                  data: widget.data,
                  progress:
                      Curves.easeOutCubic.transform(_controller.value),
                  hoveredIndex: _hoveredIndex,
                ),
                child: _hoveredIndex != null &&
                        _hoveredIndex! < widget.data.length
                    ? _buildTooltip(constraints.maxWidth)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  int? _hitIndex(Offset local, double width, int length) {
    if (length == 0) return null;
    const sidePad = 4.0;
    final chartW = width - sidePad * 2;
    final barW = chartW / length;
    final idx = ((local.dx - sidePad) / barW).floor();
    if (idx < 0 || idx >= length) return null;
    return idx;
  }

  Widget _buildTooltip(double chartWidth) {
    final item = widget.data[_hoveredIndex!];
    const sidePad = 4.0;
    final chartW = chartWidth - sidePad * 2;
    final barW = chartW / widget.data.length;
    final x = sidePad + _hoveredIndex! * barW + barW / 2;

    return Stack(
      children: [
        Positioned(
          left: (x - 50).clamp(0, chartWidth - 100),
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSolid,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(item.date),
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${item.visitCount} posjeta',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.cyan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    // DateTime.weekday: 1=Mon..7=Sun
    const days = ['Pon', 'Uto', 'Sri', 'Cet', 'Pet', 'Sub', 'Ned'];
    return '${days[d.weekday - 1]} ${d.day}.${d.month}.';
  }
}

// ── Summary chip ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          const SizedBox(width: AppSpacing.xs),
          Text(value, style: AppTextStyles.bodyBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ── Bar chart painter ────────────────────────────────────────────────

class _VisitsBarPainter extends CustomPainter {
  _VisitsBarPainter({
    required this.data,
    required this.progress,
    this.hoveredIndex,
  });

  final List<DailyVisitsDTO> data;
  final double progress;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const bottomPad = 24.0;
    const sidePad = 4.0;
    final chartH = size.height - bottomPad;
    final chartW = size.width - sidePad * 2;

    final maxVisits = data.map((d) => d.visitCount).reduce(math.max);
    final maxVal = maxVisits > 0 ? maxVisits.toDouble() : 1.0;

    final barW = chartW / data.length;
    final barGap = (barW * 0.2).clamp(1.0, 4.0);
    final barNet = barW - barGap;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(
        Offset(sidePad, y),
        Offset(size.width - sidePad, y),
        gridPaint,
      );
    }

    // Bars
    for (int i = 0; i < data.length; i++) {
      final val = data[i].visitCount;
      final barHeight = (val / maxVal) * chartH * progress;
      final x = sidePad + i * barW + barGap / 2;
      final y = chartH - barHeight;
      final isHovered = hoveredIndex == i;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barNet, barHeight),
        const Radius.circular(3),
      );

      // Bar fill
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHovered
              ? [
                  AppColors.cyan,
                  AppColors.cyan.withValues(alpha: 0.7),
                ]
              : [
                  AppColors.cyan.withValues(alpha: 0.8),
                  AppColors.cyan.withValues(alpha: 0.4),
                ],
        ).createShader(Rect.fromLTWH(x, y, barNet, barHeight));

      canvas.drawRRect(rect, barPaint);

      // Subtle glow on hover
      if (isHovered) {
        final glowPaint = Paint()
          ..color = AppColors.cyan.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(rect, glowPaint);
      }
    }

    // X-axis labels
    final labelStyle = TextStyle(
      color: AppColors.textDark,
      fontSize: 9,
    );
    final labelInterval = _labelInterval(data.length);
    for (int i = 0; i < data.length; i += labelInterval) {
      final d = data[i].date;
      final text = '${d.day}.${d.month}';
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = sidePad + i * barW + barW / 2 - tp.width / 2;
      tp.paint(canvas, Offset(x, chartH + 6));
    }
  }

  int _labelInterval(int length) {
    if (length <= 15) return 2;
    if (length <= 31) return 5;
    return 7;
  }

  @override
  bool shouldRepaint(_VisitsBarPainter old) =>
      old.progress != progress ||
      old.hoveredIndex != hoveredIndex ||
      old.data != data;
}
