import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Tier 2 — Horizontal bar chart with staggered animation. Peak bar
/// gets a gradient highlight; others use dim color.
class HorizontalBarChart extends StatefulWidget {
  const HorizontalBarChart({
    super.key,
    required this.data,
    this.accentColor = AppColors.primary,
  });

  /// List of (label, value) pairs.
  final List<({String label, double value})> data;
  final Color accentColor;

  @override
  State<HorizontalBarChart> createState() => _HorizontalBarChartState();
}

class _HorizontalBarChartState extends State<HorizontalBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(HorizontalBarChart old) {
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
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final maxVal = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final peakIdx = widget.data.indexWhere((e) => e.value == maxVal);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.data.length; i++) ...[
              _BarRow(
                label: widget.data[i].label,
                value: widget.data[i].value,
                fraction: maxVal > 0 ? widget.data[i].value / maxVal : 0,
                isPeak: i == peakIdx,
                accentColor: widget.accentColor,
                progress: _staggered(i),
              ),
              if (i < widget.data.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }

  double _staggered(int index) {
    final start = index / widget.data.length * 0.4;
    final t = ((_controller.value - start) / 0.6).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.isPeak,
    required this.accentColor,
    required this.progress,
  });

  final String label;
  final double value;
  final double fraction;
  final bool isPeak;
  final Color accentColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * fraction * progress;
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: barWidth,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: isPeak
                        ? LinearGradient(
                            colors: [accentColor, AppColors.secondary],
                          )
                        : null,
                    color: isPeak ? null : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 32,
          child: Text(
            value.toInt().toString(),
            style: AppTextStyles.bodySm.copyWith(
              color: isPeak ? accentColor : AppColors.textMuted,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
