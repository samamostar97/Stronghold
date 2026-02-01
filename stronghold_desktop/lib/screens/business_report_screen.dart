import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _BusinessReportScreenState extends State<BusinessReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Business report state
  bool _businessLoading = true;
  String? _businessError;
  BusinessReportDTO? _businessReport;

  // Inventory report state
  bool _inventoryLoading = false;
  bool _inventoryInitialized = false;
  String? _inventoryError;
  InventoryReportDTO? _inventoryReport;

  // Membership popularity state
  bool _membershipLoading = false;
  bool _membershipInitialized = false;
  String? _membershipError;
  MembershipPopularityReportDTO? _membershipReport;

  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadBusinessReport();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    switch (_tabController.index) {
      case 1:
        if (!_inventoryInitialized && !_inventoryLoading) {
          _loadInventoryReport();
        }
        break;
      case 2:
        if (!_membershipInitialized && !_membershipLoading) {
          _loadMembershipReport();
        }
        break;
    }
  }

  Future<void> _loadBusinessReport() async {
    setState(() {
      _businessLoading = true;
      _businessError = null;
    });

    try {
      final report = await ReportsApi.getBusinessReport();
      if (mounted) {
        setState(() {
          _businessReport = report;
          _businessLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _businessError = e.toString();
          _businessLoading = false;
        });
      }
    }
  }

  Future<void> _loadInventoryReport() async {
    setState(() {
      _inventoryLoading = true;
      _inventoryError = null;
    });

    try {
      final report = await ReportsApi.getInventoryReport();
      if (mounted) {
        setState(() {
          _inventoryReport = report;
          _inventoryLoading = false;
          _inventoryInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inventoryError = e.toString();
          _inventoryLoading = false;
          _inventoryInitialized = true;
        });
      }
    }
  }

  Future<void> _loadMembershipReport() async {
    setState(() {
      _membershipLoading = true;
      _membershipError = null;
    });

    try {
      final report = await ReportsApi.getMembershipPopularityReport();
      if (mounted) {
        setState(() {
          _membershipReport = report;
          _membershipLoading = false;
          _membershipInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _membershipError = e.toString();
          _membershipLoading = false;
          _membershipInitialized = true;
        });
      }
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
      if (mounted) showSuccessAnimation(context);
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
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
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

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportInventoryToExcel(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
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

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportInventoryToPdf(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
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

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportMembershipPopularityToExcel(result);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
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

    setState(() => _exporting = true);

    try {
      await ReportsApi.exportMembershipPopularityToPdf(result);
      if (mounted) showSuccessAnimation(context);
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
    final w = constraints.maxWidth;
    final statsCols = w < 600 ? 1 : (w < 900 ? 2 : 3);
    final chartsCols = w < 900 ? 1 : 2;

    if (_businessLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_businessError != null) {
      return _buildErrorState(_businessError!, _loadBusinessReport);
    }

    if (_businessReport == null) {
      return const Center(child: Text('Nema podataka', style: TextStyle(color: Colors.white)));
    }

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
                onPressed: _exporting ? null : _exportToExcel,
              ),
              const SizedBox(width: 12),
              _ExportButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                onPressed: _exporting ? null : _exportToPdf,
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
                value: '${_businessReport!.thisWeekVisits}',
                changeText: '${_pctText(_businessReport!.weekChangePct)} u odnosu na prošlu sedmicu',
                changeColor: _pctColor(_businessReport!.weekChangePct),
              ),
              _StatCard(
                label: 'Prodaja ovog mjeseca',
                value: '${_businessReport!.thisMonthRevenue.toStringAsFixed(2)} KM',
                changeText: '${_pctText(_businessReport!.monthChangePct)} u odnosu na prošli mjesec',
                changeColor: _pctColor(_businessReport!.monthChangePct),
              ),
              _StatCard(
                label: 'Aktivnih članarina',
                value: '${_businessReport!.activeMemberships}',
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
                child: _BarChart(
                  accent: AppColors.accent,
                  accent2: AppColors.accentLight,
                  muted: AppColors.muted,
                  bars: _mapBars(_businessReport!.visitsByWeekday),
                ),
              ),
              _ChartCard(
                title: 'Bestseller suplement',
                child: _BestSeller(
                  border: AppColors.border,
                  muted: AppColors.muted,
                  accent: AppColors.accent,
                  productIcon: Icons.medication_outlined,
                  productName: _businessReport!.bestsellerLast30Days?.name ?? 'N/A',
                  category: 'Suplement',
                  units: '${_businessReport!.bestsellerLast30Days?.quantitySold ?? 0}',
                  period: 'u posljednjih 30 dana',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(BoxConstraints constraints) {
    // Show loading if not initialized yet
    if (!_inventoryInitialized && !_inventoryLoading) {
      // Schedule the load for after build completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_inventoryInitialized && !_inventoryLoading) {
          _loadInventoryReport();
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (_inventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_inventoryError != null) {
      return _buildErrorState(_inventoryError!, _loadInventoryReport);
    }

    if (_inventoryReport == null) {
      return const Center(child: Text('Nema podataka', style: TextStyle(color: Colors.white)));
    }

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
                onPressed: _exporting ? null : _exportInventoryToExcel,
              ),
              const SizedBox(width: 12),
              _ExportButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                onPressed: _exporting ? null : _exportInventoryToPdf,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Ukupno proizvoda',
                  value: '${_inventoryReport!.totalProducts}',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.warning_amber_outlined,
                  label: 'Slaba prodaja',
                  value: '${_inventoryReport!.slowMovingCount}',
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Period analize',
                  value: '${_inventoryReport!.daysAnalyzed} dana',
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Products table
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
                    ],
                  ),
                ),
                if (_inventoryReport!.slowMovingProducts.isEmpty)
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
                else
                  _InventoryTable(products: _inventoryReport!.slowMovingProducts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTab(BoxConstraints constraints) {
    // Show loading if not initialized yet
    if (!_membershipInitialized && !_membershipLoading) {
      // Schedule the load for after build completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_membershipInitialized && !_membershipLoading) {
          _loadMembershipReport();
        }
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (_membershipLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_membershipError != null) {
      return _buildErrorState(_membershipError!, _loadMembershipReport);
    }

    if (_membershipReport == null) {
      return const Center(child: Text('Nema podataka', style: TextStyle(color: Colors.white)));
    }

    final topPlan = _membershipReport!.planStats.isNotEmpty
        ? _membershipReport!.planStats.first
        : null;

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
                onPressed: _exporting ? null : _exportMembershipToExcel,
              ),
              const SizedBox(width: 12),
              _ExportButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                onPressed: _exporting ? null : _exportMembershipToPdf,
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
                  value: '${_membershipReport!.totalActiveMemberships}',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.attach_money,
                  label: 'Prihod (90 dana)',
                  value: '${_membershipReport!.totalRevenueLast90Days.toStringAsFixed(2)} KM',
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
                if (_membershipReport!.planStats.isEmpty)
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
                  _MembershipTable(plans: _membershipReport!.planStats),
              ],
            ),
          ),
        ],
      ),
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
            ...products.take(15).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final isLast = index == products.take(15).length - 1;
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
    const cardHeight = 320.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: cardWidth, height: cardHeight, child: child))
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700, color: Colors.white),
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
                  style: TextStyle(fontSize: unitsSize, fontWeight: FontWeight.w800, color: accent),
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
              children: [imageWidget, const SizedBox(height: 16), infoWidget],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [imageWidget, const SizedBox(width: 24), Expanded(child: infoWidget)]),
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
