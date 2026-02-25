import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/seminar_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/seminar_card.dart';

class SeminarScreen extends ConsumerStatefulWidget {
  const SeminarScreen({super.key});

  @override
  ConsumerState<SeminarScreen> createState() => _SeminarScreenState();
}

class _SeminarScreenState extends ConsumerState<SeminarScreen> {
  final Set<int> _attendingIds = {};
  final Set<int> _cancelingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(seminarsProvider.notifier).load());
  }

  Future<void> _attend(int id) async {
    setState(() => _attendingIds.add(id));
    try {
      await ref.read(seminarsProvider.notifier).attend(id);
      if (mounted) {
        setState(() => _attendingIds.remove(id));
        await showSuccessFeedback(
            context, 'Uspjesno ste se prijavili na seminar');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _attendingIds.remove(id));
        await showErrorFeedback(
            context, ErrorHandler.message(e));
      }
    }
  }

  Future<void> _cancel(int id) async {
    setState(() => _cancelingIds.add(id));
    try {
      await ref.read(seminarsProvider.notifier).cancelAttendance(id);
      if (mounted) {
        setState(() => _cancelingIds.remove(id));
        await showSuccessFeedback(
            context, 'Uspjesno ste se odjavili sa seminara');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cancelingIds.remove(id));
        await showErrorFeedback(
            context, ErrorHandler.message(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seminarsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
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
                  child:
                      Text('Seminari', style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(child: _body(state)),
        ]),
      ),
    );
  }

  Widget _body(SeminarsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(seminarsProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.presentation,
        title: 'Nema dostupnih seminara',
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(seminarsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding),
        itemCount: state.items.length,
        itemBuilder: (_, i) {
          final s = state.items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SeminarCard(
              seminar: s,
              isAttendLoading: _attendingIds.contains(s.id),
              isCancelLoading: _cancelingIds.contains(s.id),
              onAttend: () => _attend(s.id),
              onCancel: () => _cancel(s.id),
            ),
          );
        },
      ),
    );
  }
}
