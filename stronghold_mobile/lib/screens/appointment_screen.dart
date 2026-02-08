import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/appointment_provider.dart';
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
    final s = ref.read(myAppointmentsProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !s.isLoading &&
        s.hasNextPage) {
      ref.read(myAppointmentsProvider.notifier).nextPage();
    }
  }

  Future<void> _cancel(int id) async {
    setState(() => _cancelingIds.add(id));
    try {
      await ref.read(myAppointmentsProvider.notifier).cancel(id);
      if (mounted) {
        setState(() => _cancelingIds.remove(id));
        await showSuccessFeedback(context, 'Uspjesno ste otkazali termin');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cancelingIds.remove(id));
        await showErrorFeedback(
            context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Termini', style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(child: _body(state)),
        ]),
      ),
    );
  }

  Widget _body(MyAppointmentsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myAppointmentsProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.calendar,
        title: 'Nemate zakazanih termina',
        subtitle: 'Vasi nadolazeci termini ce se prikazati ovdje',
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(myAppointmentsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding),
        itemCount: state.items.length +
            (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            );
          }
          final apt = state.items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppointmentCard(
              appointment: apt,
              isCanceling: _cancelingIds.contains(apt.id),
              onCancel: () => _cancel(apt.id),
            ),
          );
        },
      ),
    );
  }
}
