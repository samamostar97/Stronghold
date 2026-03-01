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
import '../providers/review_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/create_review_sheet.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/review_history_card.dart';

class ReviewHistoryScreen extends ConsumerStatefulWidget {
  const ReviewHistoryScreen({super.key});

  @override
  ConsumerState<ReviewHistoryScreen> createState() =>
      _ReviewHistoryScreenState();
}

class _ReviewHistoryScreenState
    extends ConsumerState<ReviewHistoryScreen> {
  int? _deletingReviewId;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(
        () => ref.read(myReviewsProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = ref.read(myReviewsProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !s.isLoading &&
        s.hasNextPage) {
      ref.read(myReviewsProvider.notifier).nextPage();
    }
  }

  void _confirmDelete(UserReviewResponse review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Obrisi recenziju',
            style: AppTextStyles.headingSm),
        content: Text(
          'Da li ste sigurni da zelite obrisati recenziju za "${review.supplementName}"?',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Odustani',
                style: AppTextStyles.buttonMd
                    .copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteReview(review);
            },
            child: Text('Obrisi',
                style: AppTextStyles.buttonMd
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(UserReviewResponse review) async {
    setState(() => _deletingReviewId = review.id);
    try {
      await ref.read(myReviewsProvider.notifier).delete(review.id);
      if (mounted) {
        setState(() => _deletingReviewId = null);
        await showSuccessFeedback(
            context, 'Recenzija uspjesno obrisana');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deletingReviewId = null);
        await showErrorFeedback(context,
            ErrorHandler.message(e));
      }
    }
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateReviewSheet(
        onReviewCreated: () {
          ref.read(myReviewsProvider.notifier).refresh();
          showSuccessFeedback(
              context, 'Recenzija uspjesno kreirana');
        },
        onError: (msg) => showErrorFeedback(context, msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReviewsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.edit,
            color: AppColors.background, size: 18),
        label: Text('Nova recenzija',
            style: AppTextStyles.buttonMd
                .copyWith(color: AppColors.background)),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Moje recenzije',
                      style: AppTextStyles.headingMd.copyWith(color: AppColors.textPrimary))),
            ]),
          ),
          Expanded(child: _body(state))
              .animate(delay: 100.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(begin: 0.04, end: 0, duration: Motion.smooth, curve: Motion.curve),
        ]),
      ),
    );
  }

  Widget _body(MyReviewsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () =>
            ref.read(myReviewsProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.edit,
        title: 'Nemate recenzija',
        subtitle: 'Vase recenzije ce se prikazati ovdje',
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(myReviewsProvider.notifier).refresh(),
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
          final review = state.items[i];
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppSpacing.md),
            child: ReviewHistoryCard(
              review: review,
              isDeleting: _deletingReviewId == review.id,
              onDelete: () => _confirmDelete(review),
            ),
          );
        },
      ),
    );
  }
}
