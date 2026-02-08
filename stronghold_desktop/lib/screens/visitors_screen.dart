import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/visit_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/checkin_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/hover_icon_button.dart';
import '../widgets/search_input.dart';
import '../widgets/success_animation.dart';
import '../widgets/visitors_table.dart';

class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends ConsumerState<VisitorsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentVisitorsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _onFilter() => setState(() {});

  Future<void> _checkOut(CurrentVisitorResponse visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda check-out',
        message: 'Zelite li odjaviti korisnika "${visitor.fullName}"?',
        confirmText: 'Check-out',
      ),
    );
    if (confirmed != true) return;
    try {
      if (visitor.visitId == 0) throw Exception('Invalid visit ID');
      await ref
          .read(currentVisitorsProvider.notifier)
          .checkOut(visitor.visitId);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'check-out'));
      }
    }
  }

  Future<void> _openCheckIn() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const CheckinDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.read(currentVisitorsProvider.notifier).load();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentVisitorsProvider);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(state),
              const SizedBox(height: AppSpacing.xxl),
              _actionBar(constraints),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _body(state)),
            ],
          ),
        ),
      );
    });
  }

  Widget _header(CurrentVisitorsState state) => Row(children: [
        Expanded(
            child: Text('Korisnici trenutno u teretani',
                style: AppTextStyles.headingMd)),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: Text('${state.visitors.length} korisnika',
              style:
                  AppTextStyles.bodyBold.copyWith(color: AppColors.primary)),
        ),
        const SizedBox(width: AppSpacing.md),
        HoverIconButton(
          icon: LucideIcons.refreshCw,
          onTap: () => ref.read(currentVisitorsProvider.notifier).load(),
          tooltip: 'Osvjezi',
        ),
      ]);

  Widget _actionBar(BoxConstraints c) {
    if (c.maxWidth < 700) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchInput(
                controller: _searchController,
                onSubmitted: (_) {},
                hintText: 'Pretrazi trenutne korisnike...'),
            const SizedBox(height: AppSpacing.md),
            GradientButton(
                text: '+ Check-in korisnika', onTap: _openCheckIn),
          ]);
    }
    return Row(children: [
      Expanded(
          child: SearchInput(
              controller: _searchController,
              onSubmitted: (_) {},
              hintText: 'Pretrazi trenutne korisnike...')),
      const SizedBox(width: AppSpacing.lg),
      GradientButton(text: '+ Check-in korisnika', onTap: _openCheckIn),
    ]);
  }

  Widget _body(CurrentVisitorsState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          Text(state.error!,
              style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            text: 'Pokusaj ponovo',
            onTap: () => ref.read(currentVisitorsProvider.notifier).load(),
          ),
        ]),
      );
    }
    if (state.visitors.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.users, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text('Nema korisnika u teretani',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),
        ]),
      );
    }
    final filtered = ref
        .read(currentVisitorsProvider.notifier)
        .filterVisitors(_searchController.text);
    if (filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.search, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text('Nema rezultata za "${_searchController.text}"',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),
        ]),
      );
    }
    return VisitorsTable(visitors: filtered, onCheckOut: _checkOut);
  }
}
