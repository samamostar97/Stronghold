import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A single bar item for [BarChart].
class BarChartItem {
  const BarChartItem({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });
  final String label;
  final double value;
  final Color color;
}

/// Animated bar chart built with CustomPainter (no chart packages).
class BarChart extends StatefulWidget {
  const BarChart({
    super.key,
    required this.items,
    this.height = 180,
    this.showLabels = true,
    this.barWidth = 24,
    this.barRadius = 4,
  });

  final List<BarChartItem> items;
  final double height;
  final bool showLabels;
  final double barWidth;
  final double barRadius;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(BarChart old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return SizedBox(height: widget.height);

    final labelHeight = widget.showLabels ? 24.0 : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BarChartPainter(
              items: widget.items,
              progress: _anim.value,
              barWidth: widget.barWidth,
              barRadius: widget.barRadius,
              labelHeight: labelHeight,
              showLabels: widget.showLabels,
            ),
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.items,
    required this.progress,
    required this.barWidth,
    required this.barRadius,
    required this.labelHeight,
    required this.showLabels,
  });

  final List<BarChartItem> items;
  final double progress;
  final double barWidth;
  final double barRadius;
  final double labelHeight;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final maxVal = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final chartHeight = size.height - labelHeight;
    final spacing = (size.width - items.length * barWidth) / (items.length + 1);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final x = spacing + i * (barWidth + spacing);
      final barH = (item.value / maxVal) * chartHeight * progress;
      final y = chartHeight - barH;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barH),
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );
      canvas.drawRRect(rrect, Paint()..color = item.color);

      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: item.label,
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: barWidth + spacing);
        tp.paint(canvas,
            Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.progress != progress || old.items != items;
}
