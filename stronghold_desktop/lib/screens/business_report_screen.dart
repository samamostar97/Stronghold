import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/reports_provider.dart';
import '../widgets/back_button.dart';
import '../widgets/error_animation.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/success_animation.dart';

/// Refactored Business Report Screen using Riverpod
class BusinessReportScreen extends ConsumerStatefulWidget {
  const BusinessReportScreen({super.key, this.onBack, this.embedded = false});

  final VoidCallback? onBack;
  final bool embedded;

  @override
  ConsumerState<BusinessReportScreen> createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends ConsumerState<BusinessReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const int _daysToAnalyze = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load paginated slow-moving products on init
    Future.microtask(() => ref.read(slowMovingProductsProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportToExcel() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj Excel izvještaj',
      fileName: 'Stronghold_Izvjestaj_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    try {
      await ref.read(exportOperationsProvider.notifier).exportBusinessToExcel(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
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

    try {
      await ref.read(exportOperationsProvider.notifier).exportBusinessToPdf(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _exportInventoryToExcel() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj Excel izvještaj',
      fileName: 'Stronghold_Inventar_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    try {
      await ref.read(exportOperationsProvider.notifier).exportInventoryToExcel(result, daysToAnalyze: _daysToAnalyze);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _exportInventoryToPdf() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvještaj',
      fileName: 'Stronghold_Inventar_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    try {
      await ref.read(exportOperationsProvider.notifier).exportInventoryToPdf(result, daysToAnalyze: _daysToAnalyze);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _exportMembershipToExcel() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj Excel izvještaj',
      fileName: 'Stronghold_Clanarine_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    try {
      await ref.read(exportOperationsProvider.notifier).exportMembershipToExcel(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _exportMembershipToPdf() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Sačuvaj PDF izvještaj',
      fileName: 'Stronghold_Clanarine_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    try {
      await ref.read(exportOperationsProvider.notifier).exportMembershipToPdf(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ===== UI helpers =====

  String _pctText(num pct) {
    final sign = pct >= 0 ? '↑' : '↓';
    final val = pct.abs().toStringAsFixed(1);
    return '$sign $val%';
  }

  Color _pctColor(num pct) => pct >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);

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
    final exportState = ref.watch(exportOperationsProvider);
    final isExporting = exportState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biznis izvještaji',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            if (isExporting)
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
        const SizedBox(height: 20),

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Pregled', icon: Icon(Icons.dashboard_outlined, size: 20)),
              Tab(text: 'Inventar', icon: Icon(Icons.inventory_2_outlined, size: 20)),
              Tab(text: 'Članarine', icon: Icon(Icons.card_membership_outlined, size: 20)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBusinessTab(constraints),
              _buildInventoryTab(constraints),
              _buildMembershipTab(constraints),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessTab(BoxConstraints constraints) {
    final businessAsync = ref.watch(businessReportProvider);
    final exportState = ref.watch(exportOperationsProvider);
    final isExporting = exportState.isLoading;

    final w = constraints.maxWidth;
    final statsCols = w < 600 ? 1 : (w < 900 ? 2 : 3);
    final chartsCols = w < 900 ? 1 : 2;
    final chartAspect = chartsCols == 1 ? (16 / 9) : (4 / 3);

    return businessAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(
        error.toString(),
        () => ref.invalidate(businessReportProvider),
      ),
      data: (report) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ExportButton(
                  icon: Icons.table_chart,
                  label: 'Excel',
                  onPressed: isExporting ? null : _exportToExcel,
                ),
                const SizedBox(width: 12),
                _ExportButton(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  onPressed: isExporting ? null : _exportToPdf,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Stats
            _StatsGrid(
              columns: statsCols,
              children: [
                _StatCard(
                  label: 'Posjete ove sedmice',
                  value: '${report.thisWeekVisits}',
                  changeText: '${_pctText(report.weekChangePct)} u odnosu na prošlu sedmicu',
                  changeColor: _pctColor(report.weekChangePct),
                ),
                _StatCard(
                  label: 'Prodaja ovog mjeseca',
                  value: '${report.thisMonthRevenue.toStringAsFixed(2)} KM',
                  changeText: '${_pctText(report.monthChangePct)} u odnosu na prošli mjesec',
                  changeColor: _pctColor(report.monthChangePct),
                ),
                _StatCard(
                  label: 'Aktivnih članarina',
                  value: '${report.activeMemberships}',
                  changeText: 'ukupno aktivnih članova',
                  changeColor: const Color(0xFF2ECC71),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Charts
            _ChartsGrid(
              columns: chartsCols,
              children: [
                _ChartCard(
                  title: 'Sedmična posjećenost po danima',
                  child: AspectRatio(
                    aspectRatio: chartAspect,
                    child: _BarChart(
                      accent: AppColors.accent,
                      accent2: AppColors.accentLight,
                      muted: AppColors.muted,
                      bars: _mapBars(report.visitsByWeekday),
                    ),
                  ),
                ),
                _ChartCard(
                  title: 'Bestseller suplement',
                  child: _BestSeller(
                    border: AppColors.border,
                    muted: AppColors.muted,
                    accent: AppColors.accent,
                    productIcon: Icons.medication_outlined,
                    productName: report.bestsellerLast30Days?.name ?? 'N/A',
                    category: 'Suplement',
                    units: '${report.bestsellerLast30Days?.quantitySold ?? 0}',
                    period: 'u posljednjih 30 dana',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab(BoxConstraints constraints) {
    final summaryAsync = ref.watch(inventorySummaryProvider(_daysToAnalyze));
    final productsState = ref.watch(slowMovingProductsProvider);
    final exportState = ref.watch(exportOperationsProvider);
    final isExporting = exportState.isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Export buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ExportButton(
                icon: Icons.table_chart,
                label: 'Excel',
                onPressed: isExporting ? null : _exportInventoryToExcel,
              ),
              const SizedBox(width: 12),
              _ExportButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                onPressed: isExporting ? null : _exportInventoryToPdf,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Summary cards (from summary endpoint)
          summaryAsync.when(
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text(
              'Greška: ${error.toString().replaceFirst('Exception: ', '')}',
              style: const TextStyle(color: Colors.red),
            ),
            data: (summary) => Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Ukupno proizvoda',
                    value: '${summary.totalProducts}',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning_amber_outlined,
                    label: 'Slaba prodaja',
                    value: '${summary.slowMovingCount}',
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Period analize',
                    value: '${summary.daysAnalyzed} dana',
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Products table (paginated)
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down, color: Color(0xFFFF9800), size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Proizvodi sa slabom prodajom (≤2 prodaje)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (productsState.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                if (productsState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          productsState.error!.replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.read(slowMovingProductsProvider.notifier).refresh(),
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  )
                else if (productsState.isEmpty && !productsState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF2ECC71), size: 48),
                          SizedBox(height: 12),
                          Text(
                            'Svi proizvodi imaju dobru prodaju!',
                            style: TextStyle(color: AppColors.muted, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _InventoryTable(products: productsState.items),
                  // Pagination controls
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: PaginationControls(
                      currentPage: productsState.currentPage,
                      totalPages: productsState.totalPages,
                      totalCount: productsState.totalCount,
                      onPageChanged: (page) {
                        ref.read(slowMovingProductsProvider.notifier).goToPage(page);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTab(BoxConstraints constraints) {
    final membershipAsync = ref.watch(membershipPopularityReportProvider);
    final exportState = ref.watch(exportOperationsProvider);
    final isExporting = exportState.isLoading;

    return membershipAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(
        error.toString(),
        () => ref.invalidate(membershipPopularityReportProvider),
      ),
      data: (report) {
        final topPlan = report.planStats.isNotEmpty ? report.planStats.first : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Export buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ExportButton(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    onPressed: isExporting ? null : _exportMembershipToExcel,
                  ),
                  const SizedBox(width: 12),
                  _ExportButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    onPressed: isExporting ? null : _exportMembershipToPdf,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.people_outline,
                      label: 'Aktivnih članarina',
                      value: '${report.totalActiveMemberships}',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.attach_money,
                      label: 'Prihod (90 dana)',
                      value: '${report.totalRevenueLast90Days.toStringAsFixed(2)} KM',
                      color: const Color(0xFF2ECC71),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top plan highlight
              if (topPlan != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.2),
                        AppColors.accentLight.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events, color: AppColors.accent, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NAJPOPULARNIJI PAKET',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topPlan.packageName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _MiniStat(
                                  label: 'Aktivnih',
                                  value: '${topPlan.activeSubscriptions}',
                                ),
                                const SizedBox(width: 24),
                                _MiniStat(
                                  label: 'Popularnost',
                                  value: '${topPlan.popularityPercentage.toStringAsFixed(1)}%',
                                ),
                                const SizedBox(width: 24),
                                _MiniStat(
                                  label: 'Prihod',
                                  value: '${topPlan.revenueLast90Days.toStringAsFixed(0)} KM',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Plans table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Statistika po paketima',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (report.planStats.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'Nema aktivnih paketa',
                            style: TextStyle(color: AppColors.muted, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      _MembershipTable(plans: report.planStats),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
          const SizedBox(height: 16),
          Text(
            error.replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pokušaj ponovo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1200
              ? 40.0
              : constraints.maxWidth > 800
                  ? 24.0
                  : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: _buildMainContent(constraints),
          );
        },
      );
    }

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

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
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
                    Expanded(child: _buildMainContent(constraints)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASSES & WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => const SharedAdminHeader();
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.products});

  final List<SlowMovingProductDTO> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Naziv', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Kategorija', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Cijena', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 1, child: Text('Prodato', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Dana bez prodaje', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                ],
              ),
            ),
            // Rows
            ...products.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final isLast = index == products.length - 1;
              final daysColor = p.daysSinceLastSale > 20
                  ? const Color(0xFFE74C3C)
                  : p.daysSinceLastSale > 10
                      ? const Color(0xFFFF9800)
                      : AppColors.muted;

              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        p.name,
                        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        p.categoryName,
                        style: const TextStyle(fontSize: 14, color: AppColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${p.price.toStringAsFixed(2)} KM',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.quantitySold == 0
                                ? const Color(0xFFE74C3C).withValues(alpha: 0.15)
                                : const Color(0xFFFF9800).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${p.quantitySold}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.quantitySold == 0 ? const Color(0xFFE74C3C) : const Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${p.daysSinceLastSale}',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: daysColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MembershipTable extends StatelessWidget {
  const _MembershipTable({required this.plans});

  final List<MembershipPlanStatsDTO> plans;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Paket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Cijena', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 1, child: Text('Aktivnih', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 1, child: Text('Novih', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Prihod (90d)', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Expanded(flex: 2, child: Text('Popularnost', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                ],
              ),
            ),
            // Rows
            ...plans.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final isLast = index == plans.length - 1;
              final popColor = p.popularityPercentage >= 30
                  ? const Color(0xFF2ECC71)
                  : p.popularityPercentage >= 10
                      ? const Color(0xFFFF9800)
                      : AppColors.muted;

              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        p.packageName,
                        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${p.packagePrice.toStringAsFixed(2)} KM',
                        style: const TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${p.activeSubscriptions}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.newSubscriptionsLast30Days > 0)
                            const Icon(Icons.arrow_upward, color: Color(0xFF2ECC71), size: 14),
                          Text(
                            '${p.newSubscriptionsLast30Days}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: p.newSubscriptionsLast30Days > 0 ? const Color(0xFF2ECC71) : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${p.revenueLast90Days.toStringAsFixed(2)} KM',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: popColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${p.popularityPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: popColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

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
              .map((child) => SizedBox(width: cardWidth, child: child))
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) => SizedBox(width: cardWidth, child: child)).toList(),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 20),
          child,
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: -25,
            child: Text(label, style: TextStyle(fontSize: 12, color: muted)),
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
      final isNarrow = constraints.maxWidth < 400;
      final isTightHeight = constraints.maxHeight > 0 && constraints.maxHeight < 210;

      final imageSize = isTightHeight
        ? (isNarrow ? 110.0 : 130.0)
        : (isNarrow ? 120.0 : 150.0);
      final iconSize = isTightHeight
        ? (isNarrow ? 54.0 : 62.0)
        : (isNarrow ? 60.0 : 70.0);
      final titleSize = isTightHeight
        ? (isNarrow ? 20.0 : 24.0)
        : (isNarrow ? 22.0 : 26.0);
      final unitsSize = isTightHeight
        ? (isNarrow ? 32.0 : 40.0)
        : (isNarrow ? 36.0 : 44.0);

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
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700, color: Colors.white),
              maxLines: isTightHeight ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: isNarrow ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 6),
            Text(
              category,
              style: TextStyle(color: muted, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isTightHeight ? 8 : 12),
            Row(
              mainAxisAlignment: isNarrow ? MainAxisAlignment.center : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  units,
                  style: TextStyle(fontSize: unitsSize, fontWeight: FontWeight.w800, color: accent),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isTightHeight ? 2 : 8),
                    child: Text(
                      'prodatih jedinica',
                      style: TextStyle(color: muted, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              period,
              style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isNarrow ? TextAlign.center : TextAlign.left,
            ),
          ],
        );

        final scaledInfoWidget = isTightHeight
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: isNarrow ? Alignment.topCenter : Alignment.topLeft,
                child: infoWidget,
              )
            : infoWidget;

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [imageWidget, const SizedBox(height: 16), scaledInfoWidget],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(isTightHeight ? 12 : 16),
          child: Row(children: [imageWidget, const SizedBox(width: 24), Expanded(child: scaledInfoWidget)]),
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
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.card.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
