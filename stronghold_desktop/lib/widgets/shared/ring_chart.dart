import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Animated donut/ring chart with two segments and a center label.
class RingChart extends StatefulWidget {
  const RingChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerValue,
    this.showLegend = true,
  });

  /// Segments to display. Each has a label, value, and color.
  final List<RingSegment> segments;

  /// Text shown above the center value (e.g. "Ukupno").
  final String centerLabel;

  /// Large number/text shown in the center.
  final String centerValue;

  /// Whether to show the legend below the ring.
  final bool showLegend;

  @override
  State<RingChart> createState() => _RingChartState();
}

class RingSegment {
  final String label;
  final double value;
  final Color color;

  const RingSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _RingChartState extends State<RingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(RingChart old) {
    super.didUpdateWidget(old);
    if (old.segments != widget.segments) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress =
                  Curves.easeOutCubic.transform(_controller.value);
              return CustomPaint(
                painter: _RingPainter(
                  segments: widget.segments,
                  total: total,
                  progress: progress,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.centerLabel,
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        widget.centerValue,
                        style: AppTextStyles.stat,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.segments.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xl),
                RingChartLegendItem(
                  color: widget.segments[i].color,
                  label: widget.segments[i].label,
                  value: widget.segments[i].value.toInt().toString(),
                  pct: total > 0
                      ? '${(widget.segments[i].value / total * 100).toStringAsFixed(0)}%'
                      : '0%',
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A single legend item for use outside the RingChart.
class RingChartLegendItem extends StatelessWidget {
  const RingChartLegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });

  final Color color;
  final String label;
  final String value;
  final String pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label  $value ($pct)',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<RingSegment> segments;
  final double total;
  final double progress;

  _RingPainter({
    required this.segments,
    required this.total,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (total <= 0) return;

    // Segments
    var startAngle = -math.pi / 2; // start from top
    const gapAngle = 0.04; // small gap between segments

    for (final seg in segments) {
      final sweep = (seg.value / total) * (2 * math.pi - gapAngle * segments.length) * progress;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.total != total;
}
