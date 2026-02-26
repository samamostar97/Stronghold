import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/list_state.dart';
import '../providers/visit_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/visitors/checkin_dialog.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/hover_icon_button.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/visitors/visitors_table.dart';

class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key});

  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends ConsumerState<VisitorsScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedOrderBy = 'checkindesc';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentVisitorsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      final q = _searchController.text.trim();
      ref
          .read(currentVisitorsProvider.notifier)
          .setSearch(q.isEmpty ? '' : q);
    });
  }

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
      if (visitor.visitId == 0) {
        throw Exception('Invalid visit ID');
      }

      await ref
          .read(currentVisitorsProvider.notifier)
          .checkOut(visitor.visitId);

      if (mounted) {
        showSuccessAnimation(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'check-out'),
        );
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
      await ref.read(currentVisitorsProvider.notifier).refresh();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentVisitorsProvider);
    final notifier = ref.read(currentVisitorsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('Posjetioci', style: AppTextStyles.pageTitle),
              ),
              if (!state.isLoading)
                Text(
                  '${state.totalCount} trenutno',
                  style: AppTextStyles.caption,
                ),
            ],
          )
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: pad,
                  vertical: AppSpacing.xl,
                ),
                child: Container(
                  padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.cardRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _actionBar(constraints, state, notifier),
                      const SizedBox(height: AppSpacing.xxl),
                      Expanded(child: _body(state, notifier)),
                    ],
                  ),
                ),
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

  Widget _countBadge(
    ListState<CurrentVisitorResponse, VisitQueryFilter> state,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryDim,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Text(
          '${state.totalCount} korisnika',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
      );

  Widget _actionBar(
    BoxConstraints constraints,
    ListState<CurrentVisitorResponse, VisitQueryFilter> state,
    CurrentVisitorsNotifier notifier,
  ) {
    final sort = _sortDropdown(notifier);

    if (constraints.maxWidth < 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi trenutne korisnike...',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [_countBadge(state)]),
          const SizedBox(height: AppSpacing.md),
          sort,
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GradientButton.text(
                    text: '+ Check-in korisnika',
                    onPressed: _openCheckIn),
              ),
              const SizedBox(width: AppSpacing.md),
              HoverIconButton(
                icon: LucideIcons.refreshCw,
                onTap: notifier.refresh,
                tooltip: 'Osvjezi',
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SearchInput(
                controller: _searchController,
                onSubmitted: (_) {},
                hintText: 'Pretrazi trenutne korisnike...',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            sort,
            const SizedBox(width: AppSpacing.lg),
            GradientButton.text(
                text: '+ Check-in korisnika', onPressed: _openCheckIn),
            const SizedBox(width: AppSpacing.md),
            HoverIconButton(
              icon: LucideIcons.refreshCw,
              onTap: notifier.refresh,
              tooltip: 'Osvjezi',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [_countBadge(state)]),
      ],
    );
  }

  Widget _sortDropdown(CurrentVisitorsNotifier notifier) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.smallRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: _selectedOrderBy,
            hint: Text('Sortiraj', style: AppTextStyles.bodySecondary),
            dropdownColor: AppColors.surface,
            style: AppTextStyles.bodyMedium,
            icon: Icon(
              LucideIcons.arrowUpDown,
              color: AppColors.textMuted,
              size: 16,
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Zadano')),
              DropdownMenuItem(
                  value: 'checkindesc', child: Text('Najnoviji dolazak')),
              DropdownMenuItem(
                  value: 'checkin', child: Text('Najstariji dolazak')),
              DropdownMenuItem(
                  value: 'firstname', child: Text('Ime (A-Z)')),
              DropdownMenuItem(
                  value: 'lastname', child: Text('Prezime (A-Z)')),
              DropdownMenuItem(
                  value: 'username', child: Text('Korisnicko ime (A-Z)')),
            ],
            onChanged: (value) {
              setState(() => _selectedOrderBy = value);
              notifier.setOrderBy(value);
            },
          ),
        ),
      );

  Widget _body(
    ListState<CurrentVisitorResponse, VisitQueryFilter> state,
    CurrentVisitorsNotifier notifier,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.error!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton.text(
                text: 'Pokusaj ponovo', onPressed: notifier.refresh),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.users, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nema korisnika u teretani',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child:
              VisitorsTable(visitors: state.items, onCheckOut: _checkOut),
        ),
        const SizedBox(height: AppSpacing.lg),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: notifier.goToPage,
        ),
      ],
    );
  }
}
