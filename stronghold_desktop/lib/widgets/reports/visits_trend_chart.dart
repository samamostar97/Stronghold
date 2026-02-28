import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Area chart showing daily visit counts over time.
/// Takes data directly — no provider needed.
class VisitsTrendChart extends StatefulWidget {
  const VisitsTrendChart({super.key, required this.data});

  final List<DailyVisitsDTO> data;

  @override
  State<VisitsTrendChart> createState() => _VisitsTrendChartState();
}

class _VisitsTrendChartState extends State<VisitsTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(VisitsTrendChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold<int>(0, (s, d) => s + d.visitCount);

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Trend posjeta', style: AppTextStyles.headingSm),
              const Spacer(),
              _SummaryChip(
                label: 'Ukupno',
                value: '$total',
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
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
                painter: _VisitsChartPainter(
                  data: widget.data,
                  progress:
                      Curves.easeOutCubic.transform(_controller.value),
                  hoveredIndex: _hoveredIndex,
                  labelInterval: _labelInterval(widget.data.length),
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

  int _labelInterval(int dataLength) {
    if (dataLength <= 31) return 5;
    if (dataLength <= 90) return 10;
    return 15;
  }

  int? _hitIndex(Offset local, double width, int length) {
    if (length == 0) return null;
    final step = width / (length - 1).clamp(1, 999);
    final idx = (local.dx / step).round();
    if (idx < 0 || idx >= length) return null;
    return idx;
  }

  Widget _buildTooltip(double chartWidth) {
    final item = widget.data[_hoveredIndex!];
    final step = chartWidth / (widget.data.length - 1).clamp(1, 999);
    final x = _hoveredIndex! * step;

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
                  '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${item.visitCount} posjeta',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Summary chip ────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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

// ── Chart painter ───────────────────────────────────────────────────────

class _VisitsChartPainter extends CustomPainter {
  _VisitsChartPainter({
    required this.data,
    required this.progress,
    this.hoveredIndex,
    this.labelInterval = 5,
  });

  final List<DailyVisitsDTO> data;
  final double progress;
  final int? hoveredIndex;
  final int labelInterval;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const bottomPad = 24.0;
    final chartH = size.height - bottomPad;
    final maxCount = data.map((d) => d.visitCount).reduce(math.max);
    final maxVal = maxCount > 0 ? maxCount.toDouble() : 1.0;
    final step =
        data.length > 1 ? size.width / (data.length - 1) : size.width;

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = chartH - (data[i].visitCount / maxVal * chartH * progress);
      points.add(Offset(x, y));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Area fill
    final areaPath = Path()..moveTo(0, chartH);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(size.width, chartH);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withValues(alpha: 0.3),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartH));

    canvas.drawPath(areaPath, areaPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Hover dot
    if (hoveredIndex != null && hoveredIndex! < points.length) {
      final hp = points[hoveredIndex!];
      canvas.drawCircle(
        hp,
        5,
        Paint()..color = AppColors.accent,
      );
      canvas.drawCircle(
        hp,
        3,
        Paint()..color = AppColors.surfaceSolid,
      );

      // Vertical guide line
      final guidePaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(
          Offset(hp.dx, hp.dy), Offset(hp.dx, chartH), guidePaint);
    }

    // X-axis labels
    final labelStyle = TextStyle(
      color: AppColors.textDark,
      fontSize: 10,
    );
    for (int i = 0; i < data.length; i += labelInterval) {
      final d = data[i].date;
      final text = '${d.day}.${d.month}';
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(i * step - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(_VisitsChartPainter old) =>
      old.progress != progress ||
      old.hoveredIndex != hoveredIndex ||
      old.data != data ||
      old.labelInterval != labelInterval;
}
