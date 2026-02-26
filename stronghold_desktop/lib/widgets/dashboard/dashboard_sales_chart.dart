import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/reports_provider.dart';

/// Period option for the sales chart dropdown.
enum _SalesPeriod {
  days30(30, '30 dana'),
  months6(180, '6 mjeseci'),
  year(365, 'Godina');

  const _SalesPeriod(this.days, this.label);
  final int days;
  final String label;
}

/// Sales chart showing daily revenue as an area chart with configurable period.
class DashboardSalesChart extends ConsumerStatefulWidget {
  const DashboardSalesChart({
    super.key,
    this.expand = false,
  });

  final bool expand;

  @override
  ConsumerState<DashboardSalesChart> createState() =>
      _DashboardSalesChartState();
}

class _DashboardSalesChartState extends ConsumerState<DashboardSalesChart>
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

  void _onPeriodChanged(_SalesPeriod period) {
    ref.read(salesPeriodProvider.notifier).state = period.days;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(salesPeriodProvider);
    final asyncData = ref.watch(salesChartDataProvider);
    final currentPeriod = _SalesPeriod.values.firstWhere(
      (p) => p.days == selectedDays,
      orElse: () => _SalesPeriod.days30,
    );

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: asyncData.when(
        loading: () => _buildShell(currentPeriod, null),
        error: (e, _) => _buildShell(currentPeriod, null, error: e.toString()),
        data: (dailySales) => _buildShell(currentPeriod, dailySales),
      ),
    );
  }

  Widget _buildShell(
    _SalesPeriod period,
    List<DailySalesDTO>? dailySales, {
    String? error,
  }) {
    final totalRevenue = dailySales?.fold<num>(0, (s, d) => s + d.revenue) ?? 0;
    final totalOrders =
        dailySales?.fold<int>(0, (s, d) => s + d.orderCount) ?? 0;

    final chartArea = dailySales != null
        ? _buildChart(dailySales)
        : error != null
            ? Center(
                child: Text(error,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.danger)))
            : const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 80;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (!compact) ...[
              Row(
                children: [
                  Text('Prodaja', style: AppTextStyles.headingSm),
                  const SizedBox(width: AppSpacing.md),
                  _PeriodDropdown(
                    value: period,
                    onChanged: _onPeriodChanged,
                  ),
                  const Spacer(),
                  if (dailySales != null) ...[
                    _SummaryChip(
                      label: 'Ukupno',
                      value: '${totalRevenue.toStringAsFixed(0)} KM',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SummaryChip(
                      label: 'Narudzbe',
                      value: '$totalOrders',
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
                  progress:
                      Curves.easeOutCubic.transform(_controller.value),
                  hoveredIndex: _hoveredIndex,
                  labelInterval: _labelInterval(dailySales.length),
                ),
                child: _hoveredIndex != null &&
                        _hoveredIndex! < dailySales.length
                    ? _buildTooltip(
                        constraints.maxWidth, dailySales)
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

// ── Period dropdown ──────────────────────────────────────────────────────

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({required this.value, required this.onChanged});

  final _SalesPeriod value;
  final ValueChanged<_SalesPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SalesPeriod>(
          value: value,
          isDense: true,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyBold,
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.textMuted, size: 18),
          items: _SalesPeriod.values
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.label, style: AppTextStyles.bodyMedium),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
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
    final step =
        data.length > 1 ? size.width / (data.length - 1) : size.width;

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
      canvas.drawCircle(
        hp,
        5,
        Paint()..color = AppColors.primary,
      );
      canvas.drawCircle(
        hp,
        3,
        Paint()..color = AppColors.surfaceSolid,
      );

      // Vertical guide line
      final guidePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
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
