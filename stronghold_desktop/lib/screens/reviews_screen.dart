import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/list_state.dart';
import '../providers/review_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';

/// Refactored Reviews Screen using Riverpod + generic patterns
/// Old: ~729 LOC | New: ~250 LOC (66% reduction)
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
    // Load data on first build
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
      ref.read(reviewListProvider.notifier).setSearch(text.isEmpty ? null : text);
    });
  }

  Future<void> _deleteReview(ReviewResponse review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da želite obrisati recenziju korisnika "${review.userName ?? "Nepoznato"}" za proizvod "${review.supplementName ?? "Nepoznato"}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(reviewListProvider.notifier).delete(review.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-review'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewListProvider);
    final notifier = ref.read(reviewListProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 1200
            ? 40.0
            : constraints.maxWidth > 800
                ? 24.0
                : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Container(
            padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upravljanje recenzijama',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 28 : 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSearchBar(constraints),
                const SizedBox(height: 24),
                Expanded(child: _buildContent(state, notifier)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 600;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretraži po korisniku ili proizvodu...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretraži po korisniku ili proizvodu...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: const Text(
            'Sortiraj',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          dropdownColor: AppColors.panel,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.sort, color: AppColors.muted, size: 20),
          items: const [
            DropdownMenuItem<String?>(value: null, child: Text('Zadano')),
            DropdownMenuItem<String?>(value: 'firstname', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem<String?>(value: 'supplement', child: Text('Proizvod (A-Z)')),
            DropdownMenuItem<String?>(value: 'createdatdesc', child: Text('Najnovije prvo')),
          ],
          onChanged: (value) {
            setState(() => _selectedOrderBy = value);
            ref.read(reviewListProvider.notifier).setOrderBy(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    ListState<ReviewResponse, ReviewQueryFilter> state,
    ReviewListNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greška pri učitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokušaj ponovo', onTap: notifier.refresh),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ReviewsTable(
            reviews: state.items,
            onDelete: _deleteReview,
          ),
        ),
        const SizedBox(height: 16),
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

// ─────────────────────────────────────────────────────────────────────────────
// STAR RATING WIDGET
// ─────────────────────────────────────────────────────────────────────────────

const _starGold = Color(0xFFFFD700);
const _starEmpty = Color(0xFF4A4D5E);

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? _starGold : _starEmpty,
            size: 18,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEWS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
  static const int user = 2;
  static const int product = 3;
  static const int rating = 2;
  static const int comment = 4;
  static const int actions = 1;
}

class _ReviewsTable extends StatelessWidget {
  const _ReviewsTable({
    required this.reviews,
    required this.onDelete,
  });

  final List<ReviewResponse> reviews;
  final ValueChanged<ReviewResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Korisnik', flex: _Flex.user),
            TableHeaderCell(text: 'Proizvod', flex: _Flex.product),
            TableHeaderCell(text: 'Ocjena', flex: _Flex.rating),
            TableHeaderCell(text: 'Komentar', flex: _Flex.comment),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: reviews.length,
      itemBuilder: (context, i) => _ReviewRow(
        review: reviews[i],
        isLast: i == reviews.length - 1,
        onDelete: () => onDelete(reviews[i]),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.review,
    required this.isLast,
    required this.onDelete,
  });

  final ReviewResponse review;
  final bool isLast;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: review.userName ?? '-', flex: _Flex.user),
          TableDataCell(text: review.supplementName ?? '-', flex: _Flex.product),
          Expanded(
            flex: _Flex.rating,
            child: _StarRating(rating: review.rating),
          ),
          Expanded(
            flex: _Flex.comment,
            child: Tooltip(
              message: review.comment ?? '',
              child: Text(
                review.comment ?? '-',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
          TableActionCell(
            flex: _Flex.actions,
            children: [
              SmallButton(
                text: 'Obriši',
                color: AppColors.accent,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
