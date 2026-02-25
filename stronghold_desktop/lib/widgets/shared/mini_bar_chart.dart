import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tier 1 — Miniature animated bar chart. Last bar gets accent color.
class MiniBarChart extends StatefulWidget {
  const MiniBarChart({
    super.key,
    required this.data,
    this.color = AppColors.primary,
    this.barWidth = 6,
    this.gap = 3,
    this.height = 36,
  });

  final List<double> data;
  final Color color;
  final double barWidth;
  final double gap;
  final double height;

  @override
  State<MiniBarChart> createState() => _MiniBarChartState();
}

class _MiniBarChartState extends State<MiniBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(MiniBarChart old) {
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
    if (widget.data.isEmpty) return SizedBox(height: widget.height);

    final totalWidth =
        widget.data.length * widget.barWidth +
        (widget.data.length - 1) * widget.gap;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: totalWidth,
          height: widget.height,
          child: CustomPaint(
            painter: _BarPainter(
              data: widget.data,
              color: widget.color,
              barWidth: widget.barWidth,
              gap: widget.gap,
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.data,
    required this.color,
    required this.barWidth,
    required this.gap,
    required this.progress,
  });

  final List<double> data;
  final Color color;
  final double barWidth;
  final double gap;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;
    final lastIdx = data.length - 1;

    for (int i = 0; i < data.length; i++) {
      final stagger = ((i + 1) / data.length).clamp(0.0, 1.0);
      final p = (progress / stagger).clamp(0.0, 1.0);
      final barH = (data[i] / maxVal) * size.height * p;
      final x = i * (barWidth + gap);
      final isLast = i == lastIdx;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - barH, barWidth, barH),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = isLast ? color : const Color(0x14FFFFFF), // white 8%
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.progress != progress || old.data != data;
}
