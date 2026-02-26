import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/reports_provider.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/reports/report_business_tab.dart';
import '../widgets/reports/report_inventory_tab.dart';
import '../widgets/reports/report_membership_tab.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
          child: Text('Izvjestaji', style: AppTextStyles.pageTitle)
              .animate()
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.06,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final pad =
                c.maxWidth > 1200 ? 40.0 : c.maxWidth > 800 ? 24.0 : 16.0;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: pad, vertical: AppSpacing.xl),
              child: _mainContent(),
            );
          })
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

  Widget _tabBar() {
    final tabs = [
      (label: 'Prihodi', icon: LucideIcons.banknote),
      (label: 'Inventar', icon: LucideIcons.package),
      (label: 'Clanarine', icon: LucideIcons.creditCard),
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.buttonRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.electric.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(tabs.length, (i) {
              final isActive = _tabController.index == i;
              return GestureDetector(
                onTap: () => _tabController.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.deepBlue : Colors.transparent,
                    borderRadius: AppSpacing.badgeRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[i].icon,
                        size: 18,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        tabs[i].label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
