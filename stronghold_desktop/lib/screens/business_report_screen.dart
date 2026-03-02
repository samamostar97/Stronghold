import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/membership_payments_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/shared/chrome_tab_bar.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/ring_chart.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/small_button.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/reports/report_business_tab.dart';
import '../widgets/reports/report_date_range_bar.dart';
import '../widgets/reports/report_staff_tab.dart';
import '../widgets/reports/report_visits_tab.dart';

class BusinessReportScreen extends ConsumerStatefulWidget {
  const BusinessReportScreen({super.key});

  @override
  ConsumerState<BusinessReportScreen> createState() =>
      _BusinessReportScreenState();
}

class _BusinessReportScreenState extends ConsumerState<BusinessReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _paymentsSearchController = TextEditingController();
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  String? _paymentsOrderBy;

  static const _tabs = [
    (label: 'Prihodi', icon: LucideIcons.banknote),
    (label: 'Osoblje', icon: LucideIcons.users),
    (label: 'Posjete', icon: LucideIcons.footprints),
    (label: 'Uplate clanarina', icon: LucideIcons.receipt),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipPaymentsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentsSearchController.dispose();
    super.dispose();
  }

  // ── Export helpers ─────────────────────────────────────────────────────

  Future<void> _export(
    String title,
    String name,
    String ext,
    Future<void> Function(String) action,
  ) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: title,
      fileName: '${name}_${DateTime.now().millisecondsSinceEpoch}.$ext',
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (path == null) return;
    try {
      await action(path);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  void _exportBusinessExcel() => _export(
    'Sacuvaj Excel izvjestaj',
    'Stronghold_Izvjestaj',
    'xlsx',
    (p) => ref.read(exportOperationsProvider.notifier).exportBusinessToExcel(p),
  );

  void _exportBusinessPdf() => _export(
    'Sacuvaj PDF izvjestaj',
    'Stronghold_Izvjestaj',
    'pdf',
    (p) => ref.read(exportOperationsProvider.notifier).exportBusinessToPdf(p),
  );

  void _exportStaffExcel() => _export(
    'Sacuvaj Excel izvjestaj',
    'Stronghold_Osoblje',
    'xlsx',
    (p) => ref.read(exportOperationsProvider.notifier).exportStaffToExcel(p),
  );

  void _exportStaffPdf() => _export(
    'Sacuvaj PDF izvjestaj',
    'Stronghold_Osoblje',
    'pdf',
    (p) => ref.read(exportOperationsProvider.notifier).exportStaffToPdf(p),
  );

  void _exportVisitsExcel() => _export(
    'Sacuvaj Excel izvjestaj',
    'Stronghold_Posjete',
    'xlsx',
    (p) => ref.read(exportOperationsProvider.notifier).exportVisitsToExcel(p),
  );

  void _exportVisitsPdf() => _export(
    'Sacuvaj PDF izvjestaj',
    'Stronghold_Posjete',
    'pdf',
    (p) => ref.read(exportOperationsProvider.notifier).exportVisitsToPdf(p),
  );

  void _exportPaymentsExcel() => _export(
    'Sacuvaj Excel izvjestaj',
    'Stronghold_Uplate',
    'xlsx',
    (p) => ref.read(exportOperationsProvider.notifier).exportMembershipPaymentsToExcel(p),
  );

  void _exportPaymentsPdf() => _export(
    'Sacuvaj PDF izvjestaj',
    'Stronghold_Uplate',
    'pdf',
    (p) => ref.read(exportOperationsProvider.notifier).exportMembershipPaymentsToPdf(p),
  );

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              LayoutBuilder(
                    builder: (context, c) {
                      final pad = c.maxWidth > 1200
                          ? 40.0
                          : c.maxWidth > 800
                          ? 24.0
                          : 16.0;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: pad,
                          vertical: AppSpacing.xl,
                        ),
                        child: _mainContent(),
                      );
                    },
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
        ),
      ],
    );
  }

  Widget _mainContent() {
    final isExporting = ref.watch(exportOperationsProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: chromeTabBarHeight,
                child: ChromeTabBar(controller: _tabController, tabs: _tabs),
              ),
            ),
            if (isExporting) ...[
              const SizedBox(width: AppSpacing.md),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ReportBusinessTab(
                onExportExcel: _exportBusinessExcel,
                onExportPdf: _exportBusinessPdf,
                isExporting: isExporting,
              ),
              ReportStaffTab(
                onExportExcel: _exportStaffExcel,
                onExportPdf: _exportStaffPdf,
                isExporting: isExporting,
              ),
              ReportVisitsTab(
                onExportExcel: _exportVisitsExcel,
                onExportPdf: _exportVisitsPdf,
                isExporting: isExporting,
              ),
              _MembershipPaymentsTab(
                dateFormat: _dateFormat,
                searchController: _paymentsSearchController,
                selectedOrderBy: _paymentsOrderBy,
                onSearchChanged: (value) {
                  ref
                      .read(membershipPaymentsProvider.notifier)
                      .setSearch(value.trim());
                },
                onSortChanged: (value) {
                  setState(() => _paymentsOrderBy = value);
                  ref
                      .read(membershipPaymentsProvider.notifier)
                      .setOrderBy(value);
                },
                onExportExcel: isExporting ? null : _exportPaymentsExcel,
                onExportPdf: isExporting ? null : _exportPaymentsPdf,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Membership Payments Tab
// ---------------------------------------------------------------------------

class _MembershipPaymentsTab extends ConsumerWidget {
  const _MembershipPaymentsTab({
    required this.dateFormat,
    required this.searchController,
    required this.selectedOrderBy,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onExportExcel,
    required this.onExportPdf,
  });

  final DateFormat dateFormat;
  final TextEditingController searchController;
  final String? selectedOrderBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  static const _packageColors = [
    AppColors.cyan,
    AppColors.electric,
    AppColors.accent,
    AppColors.success,
    AppColors.warning,
    AppColors.primary,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membershipPaymentsProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const ShimmerTable(columnFlex: [3, 3, 2, 2, 3, 2, 2]);
    }

    final totalAmount = state.data?.totalAmount ?? 0;
    final activeCount = state.data?.activeCount ?? 0;

    // Group items by package for ring chart
    final packageMap = <String, double>{};
    for (final item in state.items) {
      final name = item.packageName.isEmpty ? 'Nepoznato' : item.packageName;
      packageMap[name] = (packageMap[name] ?? 0) + item.amountPaid.toDouble();
    }
    final segments = <RingSegment>[];
    var colorIdx = 0;
    for (final entry in packageMap.entries) {
      segments.add(RingSegment(
        label: entry.key,
        value: entry.value,
        color: _packageColors[colorIdx % _packageColors.length],
      ));
      colorIdx++;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportDateRangeBar(
            onExportExcel: onExportExcel,
            onExportPdf: onExportPdf,
          ),
          const SizedBox(height: AppSpacing.xl),
          _PaymentsSummaryRow(
            totalAmount: totalAmount,
            activeCount: activeCount,
            segments: segments,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PaymentsFilters(
            searchController: searchController,
            selectedOrderBy: selectedOrderBy,
            onSearchChanged: onSearchChanged,
            onSortChanged: onSortChanged,
            onRefresh: () => ref.read(membershipPaymentsProvider.notifier).load(),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 420,
            child: state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Greska pri ucitavanju',
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error!,
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SmallButton(
                          text: 'Pokusaj ponovo',
                          color: AppColors.primary,
                          onTap: () => ref
                              .read(membershipPaymentsProvider.notifier)
                              .load(),
                        ),
                      ],
                    ),
                  )
                : GenericDataTable<AdminMembershipPaymentResponse>(
                    items: state.items,
                    emptyMessage: 'Nema uplata za prikaz.',
                    columns: [
                      ColumnDef.text(
                        label: 'Korisnik',
                        flex: 3,
                        value: (p) => p.userName,
                        bold: true,
                      ),
                      ColumnDef.text(
                        label: 'Email',
                        flex: 3,
                        value: (p) => p.userEmail,
                      ),
                      ColumnDef.text(
                        label: 'Paket',
                        flex: 2,
                        value: (p) => p.packageName,
                      ),
                      ColumnDef.text(
                        label: 'Iznos',
                        flex: 2,
                        value: (p) => '${p.amountPaid.toStringAsFixed(2)} KM',
                      ),
                      ColumnDef.text(
                        label: 'Uplata',
                        flex: 2,
                        value: (p) => dateFormat.format(p.paymentDate),
                      ),
                      ColumnDef.text(
                        label: 'Period',
                        flex: 3,
                        value: (p) =>
                            '${DateFormat('dd.MM.yyyy').format(p.startDate)} - ${DateFormat('dd.MM.yyyy').format(p.endDate)}',
                      ),
                      ColumnDef<AdminMembershipPaymentResponse>(
                        label: 'Status',
                        flex: 2,
                        cellBuilder: (p) => Align(
                          alignment: Alignment.centerLeft,
                          child: StatusPill(
                            label: p.isActive ? 'Aktivna' : 'Istekla',
                            color: p.isActive
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      ColumnDef.actions(
                        flex: 2,
                        builder: (p) => [
                          SmallButton(
                            text: 'Profil',
                            color: AppColors.primary,
                            onTap: () => context.go('/users/${p.userId}'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          PaginationControls(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalCount: state.totalCount,
            onPageChanged: (page) =>
                ref.read(membershipPaymentsProvider.notifier).goToPage(page),
          ),
        ],
      ),
    );
  }
}

class _PaymentsSummaryRow extends StatelessWidget {
  const _PaymentsSummaryRow({
    required this.totalAmount,
    required this.activeCount,
    required this.segments,
  });

  final num totalAmount;
  final int activeCount;
  final List<RingSegment> segments;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 700;

      final cards = Column(
        children: [
          _SummaryCard(
            icon: LucideIcons.banknote,
            label: 'Ukupni prihod od clanarina',
            value: '${totalAmount.toStringAsFixed(2)} KM',
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(
            icon: LucideIcons.badgeCheck,
            label: 'Broj aktivnih clanarina',
            value: '$activeCount',
            color: AppColors.success,
          ),
        ],
      );

      final ringCard = _PackageRingCard(segments: segments);

      if (wide) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: ringCard),
            ],
          ),
        );
      }

      return Column(
        children: [
          cards,
          const SizedBox(height: AppSpacing.lg),
          ringCard,
        ],
      );
    });
  }
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolid,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              Text(value,
                  style: AppTextStyles.stat.copyWith(color: color),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _PackageRingCard extends StatelessWidget {
  const _PackageRingCard({required this.segments});

  final List<RingSegment> segments;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(LucideIcons.pieChart,
                    size: 18, color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prihod po paketu', style: AppTextStyles.headingSm),
                    Text('Udio svake clanarine u ukupnoj prodaji',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: RingChart(
              centerLabel: 'Ukupno',
              centerValue: '${total.toStringAsFixed(0)} KM',
              showLegend: false,
              segments: segments,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final seg in segments)
                RingChartLegendItem(
                  color: seg.color,
                  label: seg.label,
                  value: '${seg.value.toStringAsFixed(0)} KM',
                  pct: total > 0
                      ? '${(seg.value / total * 100).toStringAsFixed(0)}%'
                      : '0%',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentsFilters extends StatelessWidget {
  const _PaymentsFilters({
    required this.searchController,
    required this.selectedOrderBy,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final String? selectedOrderBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sort = _SortDropdown(
          value: selectedOrderBy,
          onChanged: onSortChanged,
        );

        if (constraints.maxWidth < 840) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchInput(
                controller: searchController,
                onSubmitted: onSearchChanged,
                hintText: 'Pretraga po korisniku, email-u ili paketu...',
              ),
              const SizedBox(height: AppSpacing.md),
              sort,
              const SizedBox(height: AppSpacing.md),
              SmallButton(
                text: 'Osvjezi',
                color: AppColors.secondary,
                onTap: onRefresh,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SearchInput(
                controller: searchController,
                onSubmitted: onSearchChanged,
                hintText: 'Pretraga po korisniku, email-u ili paketu...',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            sort,
            const SizedBox(width: AppSpacing.md),
            SmallButton(
              text: 'Osvjezi',
              color: AppColors.secondary,
              onTap: onRefresh,
            ),
          ],
        );
      },
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text('Sort', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodySecondary,
          icon: const Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 15,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(
              value: 'datedesc',
              child: Text('Datum (najnovije)'),
            ),
            DropdownMenuItem(value: 'date', child: Text('Datum (najstarije)')),
            DropdownMenuItem(value: 'amountdesc', child: Text('Iznos (veci)')),
            DropdownMenuItem(value: 'amount', child: Text('Iznos (manji)')),
            DropdownMenuItem(value: 'user', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(value: 'userdesc', child: Text('Korisnik (Z-A)')),
            DropdownMenuItem(value: 'packagename', child: Text('Paket (A-Z)')),
            DropdownMenuItem(
              value: 'packagenamedesc',
              child: Text('Paket (Z-A)'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
