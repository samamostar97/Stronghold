import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/business_report_dto.dart';
import '../services/reports_api.dart';
import '../widgets/back_button.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/success_animation.dart';

class BusinessReportScreen extends StatefulWidget {
  const BusinessReportScreen({super.key, this.onBack, this.embedded = false});

  final VoidCallback? onBack;
  final bool embedded;

  @override
  State<BusinessReportScreen> createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends State<BusinessReportScreen> {
  bool _loading = true;
  bool _exporting = false;
  String? _error;
  BusinessReportDTO? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final report = await ReportsApi.getBusinessReport();
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _exportToExcel() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj Excel izvještaj',
      fileName: 'Stronghold_Izvjestaj_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportToExcel(result);
      if (mounted) {
        showSuccessAnimation(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportToPdf() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvještaj',
      fileName: 'Stronghold_Izvjestaj_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportToPdf(result);
      if (mounted) {
        showSuccessAnimation(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ===== UI helpers =====

  String _pctText(num pct) {
    final sign = pct >= 0 ? '↑' : '↓';
    final val = pct.abs().toStringAsFixed(1);
    return '$sign $val%';
  }

  Color _pctColor(num pct) => pct >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);

  // .NET DayOfWeek: Sunday=0..Saturday=6
  // Ti hoćeš prikaz pon->ned
  List<_BarData> _mapBars(List<WeekdayVisitsDTO> items) {
    final map = {for (final i in items) i.day: i.count};

    const order = [
      {'day': 1, 'label': 'Pon'},
      {'day': 2, 'label': 'Uto'},
      {'day': 3, 'label': 'Sri'},
      {'day': 4, 'label': 'Čet'},
      {'day': 5, 'label': 'Pet'},
      {'day': 6, 'label': 'Sub'},
      {'day': 0, 'label': 'Ned'},
    ];

    final values = order.map((o) => map[o['day'] as int] ?? 0).toList();
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

    return List.generate(order.length, (idx) {
      final label = order[idx]['label'] as String;
      final v = values[idx];
      final factor = maxVal == 0 ? 0.2 : (v / maxVal).clamp(0.2, 1.0);
      return _BarData(label: label, valueText: '$v', heightFactor: factor);
    });
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final statsCols = w < 600 ? 1 : (w < 900 ? 2 : 3);
    final chartsCols = w < 900 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biznis report',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            if (_report != null && !_exporting)
              Row(
                children: [
                  _ExportButton(
                    icon: Icons.table_chart,
                    label: 'Izvezi Excel',
                    onPressed: _exportToExcel,
                  ),
                  const SizedBox(width: 12),
                  _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Izvezi PDF',
                    onPressed: _exportToPdf,
                  ),
                ],
              ),
            if (_exporting)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // LOADING / ERROR
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Greška: $_error', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          )
        else if (_report != null) ...[
          const SizedBox(height: 18),

          // STATS
          _StatsGrid(
            columns: statsCols,
            children: [
              _StatCard(
                label: 'Ukupna posjećenost ove sedmice',
                value: '${_report!.thisWeekVisits}',
                changeText:
                    '${_pctText(_report!.weekChangePct)} u odnosu na prošlu sedmicu',
                changeColor: _pctColor(_report!.weekChangePct),
              ),
              _StatCard(
                label: 'Prodaja ovog mjeseca',
                value: '${_report!.thisMonthRevenue.toStringAsFixed(2)} KM',
                changeText:
                    '${_pctText(_report!.monthChangePct)} u odnosu na prošli mjesec',
                changeColor: _pctColor(_report!.monthChangePct),
              ),
              _StatCard(
                label: 'Aktivnih članarina',
                value: '${_report!.activeMemberships}',
                changeText: 'ukupno aktivnih članova',
                changeColor: const Color(0xFF2ECC71),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // CHARTS
          _ChartsGrid(
            columns: chartsCols,
            children: [
              _ChartCard(
                title: 'Sedmična posjećenost po danima',
                child: _BarChart(
                  accent: AppColors.accent,
                  accent2: AppColors.accentLight,
                  muted: AppColors.muted,
                  bars: _mapBars(_report!.visitsByWeekday),
                ),
              ),
              _ChartCard(
                title: 'Bestseller suplement',
                child: _BestSeller(
                  border: AppColors.border,
                  muted: AppColors.muted,
                  accent: AppColors.accent,
                  productIcon: Icons.medication_outlined,
                  productName: _report!.bestsellerLast30Days?.name ?? 'N/A',
                  category: 'Suplement',
                  units: '${_report!.bestsellerLast30Days?.quantitySold ?? 0}',
                  period: 'u posljednjih 30 dana',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Embedded mode: just return the content without Scaffold/gradient/header
    if (widget.embedded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1200
              ? 40.0
              : constraints.maxWidth > 800
                  ? 24.0
                  : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: _buildMainContent(constraints),
          );
        },
      );
    }

    // Standalone mode: full Scaffold with gradient
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 1200
                  ? 40.0
                  : constraints.maxWidth > 800
                      ? 24.0
                      : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Header(),
                      const SizedBox(height: 20),
                      AppBackButton(
                        onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 20),
                      _buildMainContent(constraints),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
class _BarData {
  final String label;
  final String valueText;
  final double heightFactor;
  const _BarData({
    required this.label,
    required this.valueText,
    required this.heightFactor,
  });
}
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SharedAdminHeader();
  }
}
// ===================
// UI WIDGETS (private)
// ===================





class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(
                    width: cardWidth,
                    child: child,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.changeText,
    required this.changeColor,
  });

  final String label;
  final String value;
  final String changeText;
  final Color changeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(changeText, style: TextStyle(fontSize: 14, color: changeColor)),
        ],
      ),
    );
  }
}

class _ChartsGrid extends StatelessWidget {
  const _ChartsGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 20.0;
    // Base height for chart cards
    const cardHeight = 320.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: child,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}



class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.bars,
    required this.accent,
    required this.accent2,
    required this.muted,
  });

  final List<_BarData> bars;
  final Color accent;
  final Color accent2;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = constraints.maxHeight;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final b in bars)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _Bar(
                      label: b.label,
                      valueText: b.valueText,
                      height: chartHeight * b.heightFactor,
                      accent: accent,
                      accent2: accent2,
                      muted: muted,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.valueText,
    required this.height,
    required this.accent,
    required this.accent2,
    required this.muted,
  });

  final String label;
  final String valueText;
  final double height;
  final Color accent;
  final Color accent2;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height.clamp(20.0, double.infinity),
              constraints: const BoxConstraints(minWidth: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent2],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ),
          Positioned(
            top: -25,
            child: Text(
              valueText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _BestSeller extends StatelessWidget {
  const _BestSeller({
    required this.border,
    required this.muted,
    required this.accent,
    required this.productIcon,
    required this.productName,
    required this.category,
    required this.units,
    required this.period,
  });

  final Color border;
  final Color muted;
  final Color accent;

  final IconData productIcon;
  final String productName;
  final String category;
  final String units;
  final String period;

  static const _bg1 = Color(0xFF2A2D3E);
  static const _bg2 = Color(0xFF1A1D2E);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: use column layout on narrow screens
        final isNarrow = constraints.maxWidth < 400;
        final imageSize = isNarrow ? 120.0 : 150.0;
        final iconSize = isNarrow ? 60.0 : 70.0;
        final titleSize = isNarrow ? 22.0 : 26.0;
        final unitsSize = isNarrow ? 36.0 : 44.0;

        final imageWidget = Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bg1, _bg2],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          alignment: Alignment.center,
          child: Icon(productIcon, color: accent, size: iconSize),
        );

        final infoWidget = Column(
          crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              productName,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: isNarrow ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 6),
            Text(category, style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
              children: [
                Text(
                  units,
                  style: TextStyle(
                    fontSize: unitsSize,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('prodatih jedinica', style: TextStyle(color: muted, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(period, style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 14)),
          ],
        );

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imageWidget,
                const SizedBox(height: 16),
                infoWidget,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              imageWidget,
              const SizedBox(width: 24),
              Expanded(child: infoWidget),
            ],
          ),
        );
      },
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
