import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/list_state.dart';
import '../providers/review_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/reviews_table.dart';
import '../widgets/search_input.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/success_animation.dart';

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
          .setSearch(text.isEmpty ? null : text);
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
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-review'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListProvider);
    final notifier = ref.read(reviewListProvider.notifier);
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
              Text('Upravljanje recenzijama', style: AppTextStyles.headingMd),
              const SizedBox(height: AppSpacing.xxl),
              _searchBar(constraints),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _content(state, notifier)),
            ],
          ),
        ),
      );
    });
  }

  Widget _searchBar(BoxConstraints c) {
    final sort = _sortDropdown();
    if (c.maxWidth < 600) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili proizvodu...'),
        const SizedBox(height: AppSpacing.md),
        sort,
      ]);
    }
    return Row(children: [
      Expanded(
          child: SearchInput(
              controller: _searchController,
              onSubmitted: (_) {},
              hintText: 'Pretrazi po korisniku ili proizvodu...')),
      const SizedBox(width: AppSpacing.lg),
      sort,
    ]);
  }

  Widget _sortDropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: _selectedOrderBy,
            hint: Text('Sortiraj', style: AppTextStyles.bodyMd),
            dropdownColor: AppColors.surfaceSolid,
            style: AppTextStyles.bodyBold,
            icon: Icon(LucideIcons.arrowUpDown,
                color: AppColors.textMuted, size: 16),
            items: const [
              DropdownMenuItem(value: null, child: Text('Zadano')),
              DropdownMenuItem(
                  value: 'firstname', child: Text('Korisnik (A-Z)')),
              DropdownMenuItem(
                  value: 'supplement', child: Text('Proizvod (A-Z)')),
              DropdownMenuItem(
                  value: 'createdatdesc', child: Text('Najnovije prvo')),
            ],
            onChanged: (v) {
              setState(() => _selectedOrderBy = v);
              ref.read(reviewListProvider.notifier).setOrderBy(v);
            },
          ),
        ),
      );

  Widget _content(
      ListState<ReviewResponse, ReviewQueryFilter> state,
      ReviewListNotifier notifier) {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [2, 3, 2, 4, 1]);
    }
    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          Text(state.error!,
              style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(text: 'Pokusaj ponovo', onTap: notifier.refresh),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
          child: ReviewsTable(reviews: state.items, onDelete: _deleteReview)),
      const SizedBox(height: AppSpacing.lg),
      PaginationControls(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        totalCount: state.totalCount,
        onPageChanged: notifier.goToPage,
      ),
    ]);
  }
}
