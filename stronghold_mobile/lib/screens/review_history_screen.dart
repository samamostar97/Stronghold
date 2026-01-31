import 'package:flutter/material.dart';
import '../models/review_models.dart';
import '../services/review_service.dart';

class ReviewHistoryScreen extends StatefulWidget {
  const ReviewHistoryScreen({super.key});

  @override
  State<ReviewHistoryScreen> createState() => _ReviewHistoryScreenState();
}

class _ReviewHistoryScreenState extends State<ReviewHistoryScreen> {
  List<Review>? _reviews;
  bool _isLoading = true;
  String? _error;
  int? _deletingReviewId;

  @override
  void initState() {
    super.initState();
    _loadReviewHistory();
  }

  Future<void> _loadReviewHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reviews = await ReviewService.getReviewHistory();
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
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
      await ReviewService.deleteReview(review.id);
      if (mounted) {
        setState(() {
          _reviews?.removeWhere((r) => r.id == review.id);
          _deletingReviewId = null;
        });
        await _showSuccessFeedback('Recenzija uspjesno obrisana');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deletingReviewId = null;
        });
        await _showErrorFeedback(e.toString().replaceFirst('Exception: ', ''));
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
          _loadReviewHistory();
          _showSuccessFeedback('Recenzija uspjesno kreirana');
        },
        onError: (message) {
          _showErrorFeedback(message);
        },
      ),
    );
  }

  Future<void> _showSuccessFeedback(String message) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FeedbackDialog(
          isSuccess: true,
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _showErrorFeedback(String message) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FeedbackDialog(
          isSuccess: false,
          message: message,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFe63946),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_reviews == null || _reviews!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildReviewList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadReviewHistory,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pokusaj ponovo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nemate recenzija',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vase recenzije ce se prikazati ovdje',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return RefreshIndicator(
      onRefresh: _loadReviewHistory,
      color: const Color(0xFFe63946),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews!.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(_reviews![index]);
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

class _CreateReviewSheet extends StatefulWidget {
  final VoidCallback onReviewCreated;
  final void Function(String message) onError;

  const _CreateReviewSheet({
    required this.onReviewCreated,
    required this.onError,
  });

  @override
  State<_CreateReviewSheet> createState() => _CreateReviewSheetState();
}

class _CreateReviewSheetState extends State<_CreateReviewSheet> {
  List<PurchasedSupplement>? _supplements;
  bool _isLoadingSupplements = true;
  String? _loadError;
  PurchasedSupplement? _selectedSupplement;
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSupplements();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadSupplements() async {
    try {
      final supplements = await ReviewService.getAvailableSupplements();
      if (mounted) {
        setState(() {
          _supplements = supplements;
          _isLoadingSupplements = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString().replaceFirst('Exception: ', '');
          _isLoadingSupplements = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_selectedSupplement == null || _rating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ReviewService.createReview(
        _selectedSupplement!.id,
        _rating,
        _commentController.text.trim().isEmpty
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
              if (_isLoadingSupplements)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFFe63946),
                    ),
                  ),
                )
              else if (_loadError != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _loadError!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (_supplements == null || _supplements!.isEmpty)
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
                      items: _supplements!.map((s) {
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
                        color:
                            const Color(0xFFe63946).withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            const Color(0xFFe63946).withValues(alpha: 0.3),
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

class _FeedbackDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;

  const _FeedbackDialog({
    required this.isSuccess,
    required this.message,
  });

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto dismiss after animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFe63946);
    final icon = widget.isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
