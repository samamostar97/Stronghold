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
import '../providers/review_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/reviews/reviews_table.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewListProvider.notifier).load();
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
      final text = _searchController.text.trim();
      ref
          .read(reviewListProvider.notifier)
          .setSearch(text.isEmpty ? '' : text);
    });
  }

  Future<void> _deleteReview(ReviewResponse review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati recenziju korisnika "${review.userName ?? "Nepoznato"}" za proizvod "${review.supplementName ?? "Nepoznato"}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(reviewListProvider.notifier).delete(review.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-review'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ReviewsContent(
            state: state,
            searchController: _searchController,
            selectedOrderBy: _selectedOrderBy,
            onSortChanged: (v) {
              setState(() => _selectedOrderBy = v);
              ref.read(reviewListProvider.notifier).setOrderBy(v);
            },
            onRefresh: ref.read(reviewListProvider.notifier).refresh,
            onPageChanged: ref.read(reviewListProvider.notifier).goToPage,
            onDelete: _deleteReview,
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
}

class _ReviewsContent extends StatelessWidget {
  const _ReviewsContent({
    required this.state,
    required this.searchController,
    required this.selectedOrderBy,
    required this.onSortChanged,
    required this.onRefresh,
    required this.onPageChanged,
    required this.onDelete,
  });

  final ListState<ReviewResponse, ReviewQueryFilter> state;
  final TextEditingController searchController;
  final String? selectedOrderBy;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onRefresh;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ReviewResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
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
              _buildSearchBar(w),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(double width) {
    final sort = _SortDropdown(
      value: selectedOrderBy,
      onChanged: onSortChanged,
    );
    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili proizvodu...',
          ),
          const SizedBox(height: AppSpacing.md),
          sort,
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili proizvodu...',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        sort,
      ],
    );
  }

  Widget _buildBody() {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [2, 3, 2, 4, 1]);
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
                text: 'Pokusaj ponovo', onPressed: onRefresh),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReviewsTable(reviews: state.items, onDelete: onDelete),
        ),
        const SizedBox(height: AppSpacing.lg),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: onPageChanged,
        ),
      ],
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
                value: 'firstname', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(
                value: 'firstnamedesc', child: Text('Korisnik (Z-A)')),
            DropdownMenuItem(
                value: 'supplement', child: Text('Proizvod (A-Z)')),
            DropdownMenuItem(
                value: 'supplementdesc', child: Text('Proizvod (Z-A)')),
            DropdownMenuItem(
                value: 'ratingdesc', child: Text('Ocjena (visa)')),
            DropdownMenuItem(value: 'rating', child: Text('Ocjena (niza)')),
            DropdownMenuItem(
                value: 'createdat', child: Text('Najstarije prvo')),
            DropdownMenuItem(
                value: 'createdatdesc', child: Text('Najnovije prvo')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
