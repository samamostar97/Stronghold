import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tier 1 — Sparkline with gradient area fill, smooth line, end dot.
/// Uses CustomPainter — no chart packages.
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.data,
    this.color = AppColors.primary,
    this.width = 80,
    this.height = 36,
  });

  final List<double> data;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(width: width, height: height);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;
    final padding = 4.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * w;
      final y = padding + h - ((data[i] - minVal) / range) * h;
      points.add(Offset(x, y));
    }

    // Area fill
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
    );
    canvas.drawPath(
      areaPath,
      Paint()..shader = gradient,
    );

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    canvas.drawCircle(
      points.last,
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
