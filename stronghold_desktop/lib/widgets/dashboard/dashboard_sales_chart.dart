import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Sales chart showing daily revenue as an area chart (last 30 days).
/// Consumes [DashboardSalesDTO] from the dedicated dashboard sales endpoint.
class DashboardSalesChart extends StatefulWidget {
  const DashboardSalesChart({
    super.key,
    this.expand = false,
    required this.data,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  final bool expand;
  final DashboardSalesDTO? data;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  State<DashboardSalesChart> createState() => _DashboardSalesChartState();
}

class _DashboardSalesChartState extends State<DashboardSalesChart>
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sales = widget.data;

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 80;

          final chartArea = sales != null && sales.dailySales.isNotEmpty
              ? _buildChart(sales.dailySales)
              : widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : widget.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.error!,
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.onRetry != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: widget.onRetry,
                          child: const Text('Pokusaj ponovo'),
                        ),
                      ],
                    ],
                  ),
                )
              : Center(
                  child: Text('Nema podataka', style: AppTextStyles.bodyMd),
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (!compact) ...[
                Row(
                  children: [
                    Text('Prodaja', style: AppTextStyles.headingSm),
                    const SizedBox(width: AppSpacing.md),
                    Text('zadnjih 30 dana', style: AppTextStyles.caption),
                    const Spacer(),
                    if (sales != null) ...[
                      _SummaryChip(
                        label: 'Ukupno',
                        value: '${sales.totalRevenue.toStringAsFixed(0)} KM',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SummaryChip(
                        label: 'Narudzbe',
                        value: '${sales.totalOrders}',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (widget.expand)
                Expanded(child: chartArea)
              else
                SizedBox(height: 200, child: chartArea),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChart(List<DailySalesDTO> dailySales) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final h = widget.expand ? constraints.maxHeight : 200.0;
            return MouseRegion(
              onHover: (event) {
                final idx = _hitIndex(
                  event.localPosition,
                  constraints.maxWidth,
                  dailySales.length,
                );
                if (idx != _hoveredIndex) setState(() => _hoveredIndex = idx);
              },
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                size: Size(constraints.maxWidth, h),
                painter: _SalesChartPainter(
                  data: dailySales,
                  progress: Curves.easeOutCubic.transform(_controller.value),
                  hoveredIndex: _hoveredIndex,
                  labelInterval: _labelInterval(dailySales.length),
                ),
                child:
                    _hoveredIndex != null && _hoveredIndex! < dailySales.length
                    ? _buildTooltip(constraints.maxWidth, dailySales)
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
    if (dataLength <= 180) return 15;
    return 30;
  }

  int? _hitIndex(Offset local, double width, int length) {
    if (length == 0) return null;
    final step = width / (length - 1).clamp(1, 999);
    final idx = (local.dx / step).round();
    if (idx < 0 || idx >= length) return null;
    return idx;
  }

  Widget _buildTooltip(double chartWidth, List<DailySalesDTO> dailySales) {
    final item = dailySales[_hoveredIndex!];
    final step = chartWidth / (dailySales.length - 1).clamp(1, 999);
    final x = _hoveredIndex! * step;

    return Stack(
      children: [
        Positioned(
          left: (x - 60).clamp(0, chartWidth - 120),
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
                  '${item.date.day}.${item.date.month}.',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${item.revenue.toStringAsFixed(0)} KM',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '${item.orderCount} narudzbi',
                  style: AppTextStyles.caption,
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

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({
    required this.data,
    required this.progress,
    this.hoveredIndex,
    this.labelInterval = 5,
  });

  final List<DailySalesDTO> data;
  final double progress;
  final int? hoveredIndex;
  final int labelInterval;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const bottomPad = 24.0;
    final chartH = size.height - bottomPad;
    final maxRev = data.map((d) => d.revenue.toDouble()).reduce(math.max);
    final maxVal = maxRev > 0 ? maxRev : 1.0;
    final step = data.length > 1 ? size.width / (data.length - 1) : size.width;

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = chartH - (data[i].revenue / maxVal * chartH * progress);
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
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartH));

    canvas.drawPath(areaPath, areaPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.primary
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
      canvas.drawCircle(hp, 5, Paint()..color = AppColors.primary);
      canvas.drawCircle(hp, 3, Paint()..color = AppColors.surfaceSolid);

      // Vertical guide line
      final guidePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(hp.dx, hp.dy), Offset(hp.dx, chartH), guidePaint);
    }

    // X-axis labels
    final labelStyle = TextStyle(color: AppColors.textDark, fontSize: 10);
    for (int i = 0; i < data.length; i += labelInterval) {
      final d = data[i].date;
      final text = labelInterval >= 30
          ? '${d.month}/${d.year % 100}'
          : '${d.day}.${d.month}';
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(i * step - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(_SalesChartPainter old) =>
      old.progress != progress ||
      old.hoveredIndex != hoveredIndex ||
      old.data != data ||
      old.labelInterval != labelInterval;
}
