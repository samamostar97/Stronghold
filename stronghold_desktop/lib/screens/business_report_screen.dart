import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/reports_provider.dart';
import '../widgets/back_button.dart';
import '../widgets/error_animation.dart';
import '../widgets/report_business_tab.dart';
import '../widgets/report_inventory_tab.dart';
import '../widgets/report_membership_tab.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/success_animation.dart';

class BusinessReportScreen extends ConsumerStatefulWidget {
  const BusinessReportScreen({super.key, this.onBack, this.embedded = false});
  final VoidCallback? onBack;
  final bool embedded;

  @override
  ConsumerState<BusinessReportScreen> createState() =>
      _BusinessReportScreenState();
}

class _BusinessReportScreenState extends ConsumerState<BusinessReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const int _daysToAnalyze = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(
        () => ref.read(slowMovingProductsProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Export helpers ─────────────────────────────────────────────────────

  Future<void> _export(String title, String name, String ext,
      Future<void> Function(String) action) async {
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
        showErrorAnimation(context,
            message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _exportBusinessExcel() => _export(
      'Sacuvaj Excel izvjestaj', 'Stronghold_Izvjestaj', 'xlsx',
      (p) => ref.read(exportOperationsProvider.notifier).exportBusinessToExcel(p));

  void _exportBusinessPdf() => _export(
      'Sacuvaj PDF izvjestaj', 'Stronghold_Izvjestaj', 'pdf',
      (p) => ref.read(exportOperationsProvider.notifier).exportBusinessToPdf(p));

  void _exportInventoryExcel() => _export(
      'Sacuvaj Excel izvjestaj', 'Stronghold_Inventar', 'xlsx',
      (p) => ref.read(exportOperationsProvider.notifier)
          .exportInventoryToExcel(p, daysToAnalyze: _daysToAnalyze));

  void _exportInventoryPdf() => _export(
      'Sacuvaj PDF izvjestaj', 'Stronghold_Inventar', 'pdf',
      (p) => ref.read(exportOperationsProvider.notifier)
          .exportInventoryToPdf(p, daysToAnalyze: _daysToAnalyze));

  void _exportMembershipExcel() => _export(
      'Sacuvaj Excel izvjestaj', 'Stronghold_Clanarine', 'xlsx',
      (p) => ref.read(exportOperationsProvider.notifier).exportMembershipToExcel(p));

  void _exportMembershipPdf() => _export(
      'Sacuvaj PDF izvjestaj', 'Stronghold_Clanarine', 'pdf',
      (p) => ref.read(exportOperationsProvider.notifier).exportMembershipToPdf(p));

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return LayoutBuilder(builder: (context, c) {
        final pad = c.maxWidth > 1200 ? 40.0 : c.maxWidth > 800 ? 24.0 : 16.0;
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: pad, vertical: AppSpacing.xl),
          child: _mainContent(),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, c) {
            final pad =
                c.maxWidth > 1200 ? 40.0 : c.maxWidth > 800 ? 24.0 : 16.0;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: pad, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SharedAdminHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  AppBackButton(
                    onTap: widget.onBack ??
                        () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(child: _mainContent()),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _mainContent() {
    final isExporting = ref.watch(exportOperationsProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: _tabBar()),
          if (isExporting) ...[
            const SizedBox(width: AppSpacing.md),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ],
        ]),
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
              ReportInventoryTab(
                daysToAnalyze: _daysToAnalyze,
                onExportExcel: _exportInventoryExcel,
                onExportPdf: _exportInventoryPdf,
                isExporting: isExporting,
              ),
              ReportMembershipTab(
                onExportExcel: _exportMembershipExcel,
                onExportPdf: _exportMembershipPdf,
                isExporting: isExporting,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBar() => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTextStyles.bodyBold,
          unselectedLabelStyle: AppTextStyles.bodyMd,
          tabs: [
            Tab(
                text: 'Prihodi',
                icon: Icon(LucideIcons.banknote, size: 20)),
            Tab(
                text: 'Inventar',
                icon: Icon(LucideIcons.package, size: 20)),
            Tab(
                text: 'Clanarine',
                icon: Icon(LucideIcons.creditCard, size: 20)),
          ],
        ),
      );
}
