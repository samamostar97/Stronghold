import 'dart:async';

import 'package:flutter/material.dart';
import '../models/nutritionist_dto.dart';
import '../services/nutritionists_api.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';
import '../utils/error_handler.dart';

class NutritionistManagementScreen extends StatefulWidget {
  const NutritionistManagementScreen({super.key});

  @override
  State<NutritionistManagementScreen> createState() => _NutritionistManagementScreenState();
}

class _NutritionistManagementScreenState extends State<NutritionistManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = _Debouncer(milliseconds: 400);

  List<NutritionistDTO> _nutritionists = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  static const int _pageSize = 10;

  // Sorting state
  String? _selectedOrderBy;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadNutritionists();
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
      setState(() {
        _currentPage = 1;
      });
      _loadNutritionists();
    });
  }

  Future<void> _loadNutritionists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await NutritionistsApi.getNutritionists(
        search: _searchController.text.trim(),
        orderBy: _selectedOrderBy,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _nutritionists = result.items;
        _totalPages = result.totalPages;
        _totalCount = result.totalCount;
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
    if (page < 1 || page > _totalPages) return;
    setState(() {
      _currentPage = page;
    });
    _loadNutritionists();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  void _onSearch() {
    setState(() {
      _currentPage = 1;
    });
    _loadNutritionists();
  }

  Future<void> _addNutritionist() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _AddNutritionistDialog(),
    );

    if (created == true) {
      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadNutritionists();
    }
  }

  Future<void> _editNutritionist(NutritionistDTO nutritionist) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditNutritionistDialog(nutritionist: nutritionist),
    );

    if (updated == true) {
      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadNutritionists();
    }
  }

  Future<void> _deleteNutritionist(NutritionistDTO nutritionist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da želite obrisati nutricionista "${nutritionist.firstName} ${nutritionist.lastName}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await NutritionistsApi.deleteNutritionist(nutritionist.id);

      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadNutritionists();
    } catch (e) {
      if (mounted) {
        String errorMessage = ErrorHandler.getContextualMessage(e, 'delete-nutritionist');
        showErrorAnimation(context, message: errorMessage);
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
            colors: [_AppColors.bg1, _AppColors.bg2],
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
                    const _Header(),
                    const SizedBox(height: 20),
                    _BackButton(onTap: () => Navigator.of(context).maybePop()),
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
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upravljanje nutricionistima',
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
          _SearchInput(
            controller: _searchController,
            onSubmitted: (_) => _onSearch(),
            hintText: 'Pretraži po imenu ili prezimenu...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
          const SizedBox(height: 12),
          _GradientButton(
            text: '+ Dodaj nutricionistu',
            onTap: _addNutritionist,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SearchInput(
            controller: _searchController,
            onSubmitted: (_) => _onSearch(),
            hintText: 'Pretraži po imenu ili prezimenu...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
        const SizedBox(width: 16),
        _GradientButton(
          text: '+ Dodaj nutricionistu',
          onTap: _addNutritionist,
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOrderBy,
          hint: const Text(
            'Sortiraj',
            style: TextStyle(color: _AppColors.muted, fontSize: 14),
          ),
          dropdownColor: _AppColors.panel,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.sort, color: _AppColors.muted, size: 20),
          items: const [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Zadano'),
            ),
            DropdownMenuItem<String?>(
              value: 'firstname',
              child: Text('Ime (A-Z)'),
            ),
            DropdownMenuItem<String?>(
              value: 'lastname',
              child: Text('Prezime (A-Z)'),
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
            _loadNutritionists();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _AppColors.accent),
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
              style: const TextStyle(color: _AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _GradientButton(text: 'Pokušaj ponovo', onTap: _loadNutritionists),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildTable(constraints)),
        const SizedBox(height: 16),
        _buildPaginationControls(constraints),
      ],
    );
  }

  Widget _buildTable(BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            if (_nutritionists.isEmpty)
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
                  itemCount: _nutritionists.length,
                  itemBuilder: (context, i) => _NutritionistTableRow(
                    nutritionist: _nutritionists[i],
                    isLast: i == _nutritionists.length - 1,
                    onEdit: () => _editNutritionist(_nutritionists[i]),
                    onDelete: () => _deleteNutritionist(_nutritionists[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BoxConstraints constraints) {
    return Column(
      children: [
        Text(
          'Ukupno: $_totalCount | Stranica $_currentPage od $_totalPages',
          style: const TextStyle(color: _AppColors.muted, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PaginationButton(
              text: '←',
              enabled: _currentPage > 1,
              onTap: _previousPage,
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
            _PaginationButton(
              text: '→',
              enabled: _currentPage < _totalPages,
              onTap: _nextPage,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageButtons = [];

    // Show first page
    if (_currentPage > 3) {
      pageButtons.add(_PaginationButton(
        text: '1',
        enabled: true,
        isActive: false,
        onTap: () => _goToPage(1),
      ));
      if (_currentPage > 4) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: _AppColors.muted)),
        ));
      }
      pageButtons.add(const SizedBox(width: 4));
    }

    // Show pages around current page
    for (int i = _currentPage - 2; i <= _currentPage + 2; i++) {
      if (i >= 1 && i <= _totalPages) {
        pageButtons.add(_PaginationButton(
          text: i.toString(),
          enabled: true,
          isActive: i == _currentPage,
          onTap: () => _goToPage(i),
        ));
        if (i < _currentPage + 2 && i < _totalPages) {
          pageButtons.add(const SizedBox(width: 4));
        }
      }
    }

    // Show last page
    if (_currentPage < _totalPages - 2) {
      pageButtons.add(const SizedBox(width: 4));
      if (_currentPage < _totalPages - 3) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: _AppColors.muted)),
        ));
      }
      pageButtons.add(_PaginationButton(
        text: _totalPages.toString(),
        enabled: true,
        isActive: false,
        onTap: () => _goToPage(_totalPages),
      ));
    }

    return pageButtons;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME COLORS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _AppColors {
  static const bg1 = Color(0xFF1A1D2E);
  static const bg2 = Color(0xFF16192B);
  static const card = Color(0xFF22253A);
  static const panel = Color(0xFF2A2D3E);
  static const border = Color(0xFF3A3D4E);
  static const muted = Color(0xFF8A8D9E);
  static const accent = Color(0xFFFF5757);
  static const accentLight = Color(0xFFFF6B6B);
  static const editBlue = Color(0xFF4A9EFF);
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SharedAdminHeader();
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _GradientButton(text: '← Nazad', onTap: onTap),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _AppColors.muted, fontSize: 14),
        filled: true,
        fillColor: _AppColors.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: _AppColors.muted),
          onPressed: () => onSubmitted(controller.text),
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
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
          transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_AppColors.accent, _AppColors.accentLight],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  const _SmallButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
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
          transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int firstName = 2;
  static const int lastName = 2;
  static const int phone = 2;
  static const int actions = 2;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          _HeaderCell(text: 'Ime', flex: _TableFlex.firstName),
          _HeaderCell(text: 'Prezime', flex: _TableFlex.lastName),
          _HeaderCell(text: 'Broj telefona', flex: _TableFlex.phone),
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



class _NutritionistTableRow extends StatefulWidget {
  const _NutritionistTableRow({
    required this.nutritionist,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final NutritionistDTO nutritionist;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_NutritionistTableRow> createState() => _NutritionistTableRowState();
}

class _NutritionistTableRowState extends State<_NutritionistTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? _AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: _AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            _DataCell(text: widget.nutritionist.firstName, flex: _TableFlex.firstName),
            _DataCell(text: widget.nutritionist.lastName, flex: _TableFlex.lastName),
            _DataCell(text: widget.nutritionist.phoneNumber ?? '-', flex: _TableFlex.phone),
            
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _SmallButton(
                    text: 'Izmijeni',
                    color: _AppColors.editBlue,
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  _SmallButton(
                    text: 'Obriši',
                    color: _AppColors.accent,
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

class _DataCell extends StatelessWidget {
  const _DataCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Odustani', style: TextStyle(color: _AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            backgroundColor: _AppColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Obriši', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD NUTRITIONIST DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddNutritionistDialog extends StatefulWidget {
  const _AddNutritionistDialog(); 
  @override
  State<_AddNutritionistDialog> createState() => _AddNutritionistDialogState();
}

class _AddNutritionistDialogState extends State<_AddNutritionistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = CreateNutritionistDTO(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await NutritionistsApi.createNutritionist(dto);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        // Small delay to ensure dialog is fully closed before showing animation
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'create-nutritionist');
          showErrorAnimation(context, message: errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        'Dodaj nutricionistu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: _AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: _AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AppColors.accent,
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
// EDIT NUTRITIONIST DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _EditNutritionistDialog extends StatefulWidget {
  const _EditNutritionistDialog({required this.nutritionist});
  final NutritionistDTO nutritionist;

  @override
  State<_EditNutritionistDialog> createState() => _EditNutritionistDialogState();
}

class _EditNutritionistDialogState extends State<_EditNutritionistDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.nutritionist.firstName);
    _lastNameController = TextEditingController(text: widget.nutritionist.lastName);
    _emailController = TextEditingController(text: widget.nutritionist.email);
    _phoneController = TextEditingController(text: widget.nutritionist.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = UpdateNutritionistDTO(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await NutritionistsApi.updateNutritionist(widget.nutritionist.id, dto);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(false);

        // Small delay to ensure dialog is fully closed before showing animation
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'update-nutritionist');
          showErrorAnimation(context, message: errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        'Izmijeni nutricionistu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: _AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogTextField(
                          controller: _firstNameController,
                          label: 'Ime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogTextField(
                          controller: _lastNameController,
                          label: 'Prezime',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obavezno polje' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DialogTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obavezno polje';
                      if (!v.contains('@')) return 'Unesite validan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DialogTextField(
                    controller: _phoneController,
                    label: 'Broj telefona',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: _AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AppColors.accent,
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
// DIALOG TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _AppColors.muted, fontSize: 14),
        filled: true,
        fillColor: _AppColors.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _AppColors.accent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _AppColors.accent),
          borderRadius: BorderRadius.circular(8),
        ),
        errorStyle: const TextStyle(color: _AppColors.accent),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _PaginationButton extends StatefulWidget {
  const _PaginationButton({
    required this.text,
    required this.enabled,
    required this.onTap,
    this.isActive = false,
  });

  final String text;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _AppColors.accent
                : widget.enabled && _hover
                    ? _AppColors.panel
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.enabled ? _AppColors.border : _AppColors.muted.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.enabled ? Colors.white : _AppColors.muted.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEBOUNCER
// ─────────────────────────────────────────────────────────────────────────────

class _Debouncer {
  _Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
