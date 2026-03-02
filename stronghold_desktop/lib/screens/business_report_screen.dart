import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/motion.dart';
import '../providers/reports_provider.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/reports/report_business_tab.dart';
import '../widgets/reports/report_staff_tab.dart';
import '../widgets/reports/report_visits_tab.dart';
import '../widgets/shared/chrome_tab_bar.dart';
import '../widgets/shared/success_animation.dart';

class BusinessReportScreen extends ConsumerStatefulWidget {
  const BusinessReportScreen({super.key});

  @override
  ConsumerState<BusinessReportScreen> createState() =>
      _BusinessReportScreenState();
}

class _BusinessReportScreenState extends ConsumerState<BusinessReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = [
    (label: 'Prihodi', icon: LucideIcons.banknote),
    (label: 'Osoblje', icon: LucideIcons.users),
    (label: 'Posjete', icon: LucideIcons.footprints),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            ],
          ),
        ),
      ],
    );
  }
}
