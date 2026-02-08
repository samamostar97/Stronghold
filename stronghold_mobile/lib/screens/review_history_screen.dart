import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_models.dart';
import '../providers/review_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class ReviewHistoryScreen extends ConsumerStatefulWidget {
  const ReviewHistoryScreen({super.key});

  @override
  ConsumerState<ReviewHistoryScreen> createState() => _ReviewHistoryScreenState();
}

class _ReviewHistoryScreenState extends ConsumerState<ReviewHistoryScreen> {
  int? _deletingReviewId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(myReviewsProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(myReviewsProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(myReviewsProvider.notifier).nextPage();
    }
  }

  void _onDeleteReview(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFe63946).withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          'Obrisi recenziju',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Da li ste sigurni da zelite obrisati recenziju za "${review.supplementName}"?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Odustani',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(review);
            },
            child: const Text(
              'Obrisi',
              style: TextStyle(
                color: Color(0xFFe63946),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    setState(() {
      _deletingReviewId = review.id;
    });

    try {
      await ref.read(myReviewsProvider.notifier).delete(review.id);
      if (mounted) {
        setState(() {
          _deletingReviewId = null;
        });
        await showSuccessFeedback(context, 'Recenzija uspjesno obrisana');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deletingReviewId = null;
        });
        await showErrorFeedback(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showCreateReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateReviewSheet(
        onReviewCreated: () {
          ref.read(myReviewsProvider.notifier).refresh();
          showSuccessFeedback(context, 'Recenzija uspjesno kreirana');
        },
        onError: (message) {
          showErrorFeedback(context, message);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(myReviewsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Moje recenzije',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateReviewSheet,
        backgroundColor: const Color(0xFFe63946),
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text(
          'Nova recenzija',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: _buildContent(reviewState),
        ),
      ),
    );
  }

  Widget _buildContent(MyReviewsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }

    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(myReviewsProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.rate_review_outlined,
        title: 'Nemate recenzija',
        subtitle: 'Vase recenzije ce se prikazati ovdje',
      );
    }

    return _buildReviewList(state);
  }

  Widget _buildReviewList(MyReviewsState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(myReviewsProvider.notifier).refresh(),
      color: const Color(0xFFe63946),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFFe63946)),
              ),
            );
          }
          return _buildReviewCard(state.items[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  review.supplementName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRatingStars(review.rating),
            ],
          ),
          const SizedBox(height: 12),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.rating}/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _deletingReviewId == review.id
                    ? null
                    : () => _onDeleteReview(review),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe63946).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFe63946).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: _deletingReviewId == review.id
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFe63946),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: const Color(0xFFe63946).withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Obrisi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFe63946).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 18,
          color: index < rating
              ? const Color(0xFFFFD700)
              : Colors.white.withValues(alpha: 0.3),
        );
      }),
    );
  }
}

class _CreateReviewSheet extends ConsumerStatefulWidget {
  final VoidCallback onReviewCreated;
  final void Function(String message) onError;

  const _CreateReviewSheet({
    required this.onReviewCreated,
    required this.onError,
  });

  @override
  ConsumerState<_CreateReviewSheet> createState() => _CreateReviewSheetState();
}

class _CreateReviewSheetState extends ConsumerState<_CreateReviewSheet> {
  PurchasedSupplement? _selectedSupplement;
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(availableSupplementsProvider.notifier).load());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final supplement = _selectedSupplement;
    if (supplement == null || _rating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(createReviewProvider.notifier).create(
        supplementId: supplement.id,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onReviewCreated();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        widget.onError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplementsState = ref.watch(availableSupplementsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: Color(0xFFe63946),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Nova recenzija',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (supplementsState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFFe63946),
                    ),
                  ),
                )
              else if (supplementsState.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      supplementsState.error!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (supplementsState.items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nemate suplemenata dostupnih za recenziju',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else ...[
                Text(
                  'Suplement',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFe63946).withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PurchasedSupplement>(
                      value: _selectedSupplement,
                      hint: Text(
                        'Odaberite suplement',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF16213e),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      items: supplementsState.items.map((s) {
                        return DropdownMenuItem<PurchasedSupplement>(
                          value: s,
                          child: Text(
                            s.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplement = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ocjena',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = starIndex;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starIndex <= _rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 36,
                          color: starIndex <= _rating
                              ? const Color(0xFFFFD700)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  'Komentar (opciono)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Napisite komentar...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF16213e),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFFe63946).withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFFe63946).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFe63946),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: (_selectedSupplement == null ||
                            _rating == 0 ||
                            _isSubmitting)
                        ? null
                        : _submitReview,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: (_selectedSupplement == null ||
                                _rating == 0 ||
                                _isSubmitting)
                            ? const Color(0xFFe63946).withValues(alpha: 0.3)
                            : const Color(0xFFe63946),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Ostavi recenziju',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
