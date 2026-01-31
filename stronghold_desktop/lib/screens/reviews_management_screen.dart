import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/review_dto.dart';
import '../services/reviews_api.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/back_button.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/search_input.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';

class ReviewsManagementScreen extends StatefulWidget {
  const ReviewsManagementScreen({super.key});

  @override
  State<ReviewsManagementScreen> createState() => _ReviewsManagementScreenState();
}

class _ReviewsManagementScreenState extends State<ReviewsManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

  List<ReviewDTO> _reviews = [];
  bool _isLoading = true;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 10;

  // Sorting state
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadReviews();
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
      _currentPage = 1;
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ReviewsApi.getReviews(
        search: _searchController.text.trim(),
        orderBy: _selectedOrderBy,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _reviews = result.items;
        _totalCount = result.totalCount;
        _totalPages = result.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() => _currentPage = page);
    _loadReviews();
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() => _goToPage(_currentPage - 1);

  void _onSearch() {
    _loadReviews();
  }

  Future<void> _deleteReview(ReviewDTO review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da želite obrisati recenziju korisnika "${review.userName}" za proizvod "${review.supplementName}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await ReviewsApi.deleteReview(review.id);
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadReviews();
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 1200
                  ? 40.0
                  : constraints.maxWidth > 800
                      ? 24.0
                      : 16.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SharedAdminHeader(),
                    const SizedBox(height: 20),
                    AppBackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 20),
                    Expanded(child: _buildMainContent(constraints)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    return Container(
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
          Expanded(child: _buildContent(constraints)),
        ],
      ),
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
            onSubmitted: (_) => _onSearch(),
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
            onSubmitted: (_) => _onSearch(),
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
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Zadano'),
            ),
            DropdownMenuItem<String?>(
              value: 'firstname',
              child: Text('Korisnik (A-Z)'),
            ),
            DropdownMenuItem<String?>(
              value: 'supplement',
              child: Text('Proizvod (A-Z)'),
            ),
            DropdownMenuItem<String?>(
              value: 'createdatdesc',
              child: Text('Najnovije prvo'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOrderBy = value;
              _currentPage = 1;
            });
            _loadReviews();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
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
              _error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokušaj ponovo', onTap: _loadReviews),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildTable(constraints)),
        const SizedBox(height: 16),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ukupno: $_totalCount',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(width: 24),
        _PaginationButton(
          icon: Icons.chevron_left,
          onTap: _currentPage > 1 ? _previousPage : null,
        ),
        const SizedBox(width: 8),
        ..._buildPageNumbers(),
        const SizedBox(width: 8),
        _PaginationButton(
          icon: Icons.chevron_right,
          onTap: _currentPage < _totalPages ? _nextPage : null,
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    const maxVisible = 5;

    int start = (_currentPage - maxVisible ~/ 2).clamp(1, _totalPages);
    int end = (start + maxVisible - 1).clamp(1, _totalPages);
    start = (end - maxVisible + 1).clamp(1, _totalPages);

    if (start > 1) {
      pages.add(_PageNumber(page: 1, isActive: false, onTap: () => _goToPage(1)));
      if (start > 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: AppColors.muted)),
        ));
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_PageNumber(
        page: i,
        isActive: i == _currentPage,
        onTap: () => _goToPage(i),
      ));
    }

    if (end < _totalPages) {
      if (end < _totalPages - 1) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: AppColors.muted)),
        ));
      }
      pages.add(_PageNumber(
        page: _totalPages,
        isActive: false,
        onTap: () => _goToPage(_totalPages),
      ));
    }

    return pages;
  }

  Widget _buildTable(BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            if (_reviews.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Nema rezultata.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _reviews.length,
                  itemBuilder: (context, i) => _ReviewTableRow(
                    review: _reviews[i],
                    isLast: i == _reviews.length - 1,
                    onDelete: () => _deleteReview(_reviews[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAR RATING WIDGET (screen-specific colors)
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
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int user = 2;
  static const int product = 3;
  static const int rating = 2;
  static const int comment = 4;
  static const int actions = 1;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          _HeaderCell(text: 'Korisnik', flex: _TableFlex.user),
          _HeaderCell(text: 'Proizvod', flex: _TableFlex.product),
          _HeaderCell(text: 'Ocjena', flex: _TableFlex.rating),
          _HeaderCell(text: 'Komentar', flex: _TableFlex.comment),
          _HeaderCell(text: 'Akcije', flex: _TableFlex.actions, alignRight: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex, this.alignRight = false});

  final String text;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ReviewTableRow extends StatefulWidget {
  const _ReviewTableRow({
    required this.review,
    required this.isLast,
    required this.onDelete,
  });

  final ReviewDTO review;
  final bool isLast;
  final VoidCallback onDelete;

  @override
  State<_ReviewTableRow> createState() => _ReviewTableRowState();
}

class _ReviewTableRowState extends State<_ReviewTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              flex: _TableFlex.user,
              child: Text(
                widget.review.userName,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: _TableFlex.product,
              child: Text(
                widget.review.supplementName,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: _TableFlex.rating,
              child: _StarRating(rating: widget.review.rating),
            ),
            Expanded(
              flex: _TableFlex.comment,
              child: Tooltip(
                message: widget.review.comment ?? '',
                child: Text(
                  widget.review.comment ?? '-',
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SmallButton(
                    text: 'Obriši',
                    color: AppColors.accent,
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _PaginationButton extends StatefulWidget {
  const _PaginationButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _hover = true) : null,
      onExit: isEnabled ? (_) => setState(() => _hover = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hover && isEnabled ? AppColors.accent : AppColors.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            widget.icon,
            color: isEnabled ? Colors.white : AppColors.muted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatefulWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_PageNumber> createState() => _PageNumberState();
}

class _PageNumberState extends State<_PageNumber> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent
                : _hover
                    ? AppColors.panel
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive ? null : Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              '${widget.page}',
              style: TextStyle(
                color: widget.isActive ? Colors.white : AppColors.muted,
                fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
