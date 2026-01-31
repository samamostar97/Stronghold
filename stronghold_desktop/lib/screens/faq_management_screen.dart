import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/faq_dto.dart';
import '../services/faq_api.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/back_button.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/search_input.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';

class FaqManagementScreen extends StatefulWidget {
  const FaqManagementScreen({super.key});

  @override
  State<FaqManagementScreen> createState() => _FaqManagementScreenState();
}

class _FaqManagementScreenState extends State<FaqManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

  List<FaqDTO> _faqs = [];
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
    _loadFaqs();
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
      _loadFaqs();
    });
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await FaqApi.getFaqs(
        search: _searchController.text.trim(),
        orderBy: _selectedOrderBy,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _faqs = result.items;
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
    _loadFaqs();
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() => _goToPage(_currentPage - 1);

  void _onSearch() {
    _loadFaqs();
  }

  Future<void> _addFaq() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _AddFaqDialog(),
    );

    if (created == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadFaqs();
    }
  }

  Future<void> _editFaq(FaqDTO faq) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditFaqDialog(faq: faq),
    );

    if (updated == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadFaqs();
    }
  }

  Future<void> _deleteFaq(FaqDTO faq) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati ovo pitanje?',
      ),
    );

    if (confirmed != true) return;

    try {
      await FaqApi.deleteFaq(faq.id);
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadFaqs();
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'delete-faq'),
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
            'Upravljanje FAQ-om',
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
            hintText: 'Pretrazi pitanja...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
          const SizedBox(height: 12),
          GradientButton(
            text: '+ Dodaj FAQ',
            onTap: _addFaq,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: _searchController,
            onSubmitted: (_) => _onSearch(),
            hintText: 'Pretrazi pitanja...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
        const SizedBox(width: 16),
        GradientButton(
          text: '+ Dodaj FAQ',
          onTap: _addFaq,
        ),
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
              value: 'createdatdesc',
              child: Text('Najnovije prvo'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOrderBy = value;
              _currentPage = 1;
            });
            _loadFaqs();
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
              'Greska pri ucitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokusaj ponovo', onTap: _loadFaqs),
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
            if (_faqs.isEmpty)
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
                  itemCount: _faqs.length,
                  itemBuilder: (context, i) => _FaqTableRow(
                    faq: _faqs[i],
                    isLast: i == _faqs.length - 1,
                    onEdit: () => _editFaq(_faqs[i]),
                    onDelete: () => _deleteFaq(_faqs[i]),
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
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int question = 4;
  static const int answer = 5;
  static const int actions = 2;
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
          _HeaderCell(text: 'Pitanje', flex: _TableFlex.question),
          _HeaderCell(text: 'Odgovor', flex: _TableFlex.answer),
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

class _FaqTableRow extends StatefulWidget {
  const _FaqTableRow({
    required this.faq,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final FaqDTO faq;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_FaqTableRow> createState() => _FaqTableRowState();
}

class _FaqTableRowState extends State<_FaqTableRow> {
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
              flex: _TableFlex.question,
              child: Tooltip(
                message: widget.faq.question,
                child: Text(
                  widget.faq.question,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            Expanded(
              flex: _TableFlex.answer,
              child: Tooltip(
                message: widget.faq.answer,
                child: Text(
                  widget.faq.answer,
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
                    text: 'Izmijeni',
                    color: AppColors.editBlue,
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  SmallButton(
                    text: 'Obrisi',
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
// DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

class _AddFaqDialog extends StatefulWidget {
  const _AddFaqDialog();

  @override
  State<_AddFaqDialog> createState() => _AddFaqDialogState();
}

class _AddFaqDialogState extends State<_AddFaqDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = CreateFaqDTO(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      );

      await FaqApi.createFaq(dto);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          showErrorAnimation(
            context,
            message: ErrorHandler.getContextualMessage(e, 'create-faq'),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dodaj FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _questionController,
                    label: 'Pitanje',
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _answerController,
                    label: 'Odgovor',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditFaqDialog extends StatefulWidget {
  const _EditFaqDialog({required this.faq});

  final FaqDTO faq;

  @override
  State<_EditFaqDialog> createState() => _EditFaqDialogState();
}

class _EditFaqDialogState extends State<_EditFaqDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.faq.question);
    _answerController = TextEditingController(text: widget.faq.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = UpdateFaqDTO(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      );

      await FaqApi.updateFaq(widget.faq.id, dto);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          showErrorAnimation(
            context,
            message: ErrorHandler.getContextualMessage(e, 'update-faq'),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Izmijeni FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _questionController,
                    label: 'Pitanje',
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _answerController,
                    label: 'Odgovor',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
