import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/appointment_card.dart';
import '../widgets/feedback_dialog.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final Set<int> _cancelingIds = {};
  final ScrollController _scrollCtrl = ScrollController();
  _AppointmentTypeFilter _selectedFilter = _AppointmentTypeFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(myAppointmentsProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(myAppointmentsProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(myAppointmentsProvider.notifier).nextPage();
    }
  }

  Future<void> _cancel(int id) async {
    setState(() => _cancelingIds.add(id));
    try {
      await ref.read(myAppointmentsProvider.notifier).cancel(id);
      if (!mounted) return;
      setState(() => _cancelingIds.remove(id));
      await showSuccessFeedback(context, 'Uspjesno ste otkazali termin');
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelingIds.remove(id));
      await showErrorFeedback(context, ErrorHandler.message(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myAppointmentsProvider);
    final canGoBack = Navigator.of(context).canPop();
    final filteredItems = _filteredItems(state);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  if (canGoBack)
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: AppSpacing.touchTarget,
                        height: AppSpacing.touchTarget,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeft,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  if (!canGoBack)
                    Container(
                      width: AppSpacing.touchTarget,
                      height: AppSpacing.touchTarget,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        LucideIcons.calendarClock,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text('Termini', style: AppTextStyles.headingMd),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _newAppointmentButton(context),
                ],
              ),
            ),
            _typeFilterControl(state),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _body(state, filteredItems)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: Motion.smooth,
                    curve: Motion.curve,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newAppointmentButton(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 380;
    return InkWell(
      onTap: () => context.push('/book-appointment'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.plus, color: Colors.white, size: 14),
            if (!compact) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Novi termin',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typeFilterControl(MyAppointmentsState state) {
    final counts = _typeCounts(state);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final filter in _AppointmentTypeFilter.values)
              _filterChip(
                filter: filter,
                count: counts[filter] ?? 0,
                active: _selectedFilter == filter,
                onTap: () => setState(() => _selectedFilter = filter),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required _AppointmentTypeFilter filter,
    required int count,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.label,
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primary : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<_AppointmentTypeFilter, int> _typeCounts(MyAppointmentsState state) {
    final trainer = state.items.where((a) => a.trainerName != null).length;
    final nutritionist = state.items
        .where((a) => a.nutritionistName != null)
        .length;
    return {
      _AppointmentTypeFilter.all: state.items.length,
      _AppointmentTypeFilter.trainer: trainer,
      _AppointmentTypeFilter.nutritionist: nutritionist,
    };
  }

  List<UserAppointmentResponse> _filteredItems(MyAppointmentsState state) {
    final items = switch (_selectedFilter) {
      _AppointmentTypeFilter.all => [...state.items],
      _AppointmentTypeFilter.trainer =>
        state.items.where((a) => a.trainerName != null).toList(),
      _AppointmentTypeFilter.nutritionist =>
        state.items.where((a) => a.nutritionistName != null).toList(),
    };
    items.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return items;
  }

  Widget _body(
    MyAppointmentsState state,
    List<UserAppointmentResponse> filteredItems,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myAppointmentsProvider.notifier).load(),
      );
    }
    if (filteredItems.isEmpty) {
      return AppEmptyState(
        icon: LucideIcons.calendar,
        title: _selectedFilter.emptyTitle,
        subtitle: _selectedFilter.emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myAppointmentsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount:
            filteredItems.length +
            (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == filteredItems.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          }
          final appointment = filteredItems[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppointmentCard(
              appointment: appointment,
              isCanceling: _cancelingIds.contains(appointment.id),
              onCancel: () => _cancel(appointment.id),
            ),
          );
        },
      ),
    );
  }
}

enum _AppointmentTypeFilter { all, trainer, nutritionist }

extension _AppointmentTypeFilterX on _AppointmentTypeFilter {
  String get label {
    return switch (this) {
      _AppointmentTypeFilter.all => 'Sve',
      _AppointmentTypeFilter.trainer => 'Trening',
      _AppointmentTypeFilter.nutritionist => 'Nutricionista',
    };
  }

  String get emptyTitle {
    return switch (this) {
      _AppointmentTypeFilter.all => 'Nemate zakazanih termina',
      _AppointmentTypeFilter.trainer => 'Nemate zakazanih treninga',
      _AppointmentTypeFilter.nutritionist => 'Nemate nutricionistickih termina',
    };
  }

  String get emptySubtitle {
    return switch (this) {
      _AppointmentTypeFilter.all => 'Vasi termini ce se prikazati ovdje.',
      _AppointmentTypeFilter.trainer =>
        'Kada zakazete trening, prikazat ce se ovdje.',
      _AppointmentTypeFilter.nutritionist =>
        'Kada zakazete nutricionistu, prikazat ce se ovdje.',
    };
  }
}
