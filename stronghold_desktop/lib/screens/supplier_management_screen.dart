import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stronghold_desktop/services/suppliers_api.dart';
import '../models/supplier_dto.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';
import '../utils/error_handler.dart';


class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = _Debouncer(milliseconds: 400);

  List<SupplierDTO> _suppliers = [];
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
    _loadSuppliers();
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
      _loadSuppliers();
    });
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await SuppliersApi.getSuppliers(
        search: _searchController.text.trim(),
        orderBy: _selectedOrderBy,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _suppliers = result.items;
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
    _loadSuppliers();
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
    _loadSuppliers();
  }

  Future<void> _addSupplier() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _AddSupplierDialog(),
    );

    if (created == true) {
      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadSuppliers();
    }
  }

  Future<void> _editSupplier(SupplierDTO supplier) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditSupplierDialog(supplier: supplier),
    );

    if (updated == true) {
      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadSuppliers();
    }
  }

  Future<void> _deleteSupplier(SupplierDTO supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da želite obrisati dobavljača "${supplier.name}"?',
      ),
    );

    if (confirmed != true) return;

    try {
      await SuppliersApi.deleteSupplier(supplier.id);

      // Small delay to ensure dialog is fully closed before showing animation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadSuppliers();
    } catch (e) {
      if (mounted) {
        String errorMessage = ErrorHandler.getContextualMessage(e, 'delete-supplier');
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
            'Upravljanje dobavljačima',
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
            hintText: 'Pretraži po nazivu...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
          const SizedBox(height: 12),
          _GradientButton(
            text: '+ Dodaj dobavljača',
            onTap: _addSupplier,
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
            hintText: 'Pretraži po nazivu...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
        const SizedBox(width: 16),
        _GradientButton(
          text: '+ Dodaj dobavljača',
          onTap: _addSupplier,
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
              value: 'naziv',
              child: Text('Naziv (A-Z)'),
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
            _loadSuppliers();
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
            _GradientButton(text: 'Pokušaj ponovo', onTap: _loadSuppliers),
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
            if (_suppliers.isEmpty)
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
                  itemCount: _suppliers.length,
                  itemBuilder: (context, i) => _SupplierTableRow(
                    supplier: _suppliers[i],
                    isLast: i == _suppliers.length - 1,
                    onEdit: () => _editSupplier(_suppliers[i]),
                    onDelete: () => _deleteSupplier(_suppliers[i]),
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
          transform: Matrix4.translationValues(0.0, _hover ? -2.0 : 0.0, 0.0),
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
          transform: Matrix4.translationValues(0.0, _hover ? -2.0 : 0.0, 0.0),
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
  static const int name = 3;
  static const int website = 3;

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
          _HeaderCell(text: 'Naziv', flex: _TableFlex.name),
          _HeaderCell(text: 'Web stranica', flex: _TableFlex.website),
          // Empty spacer for actions column alignment
          Expanded(flex: _TableFlex.actions, child: SizedBox()),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SupplierTableRow extends StatefulWidget {
  const _SupplierTableRow({
    required this.supplier,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplierDTO supplier;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_SupplierTableRow> createState() => _SupplierTableRowState();
}

class _SupplierTableRowState extends State<_SupplierTableRow> {
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
            _DataCell(text: widget.supplier.name, flex: _TableFlex.name),
            _DataCell(text: widget.supplier.website ?? '-', flex: _TableFlex.website),
            
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
// ADD SUPPLEMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddSupplierDialog extends StatefulWidget {
  const _AddSupplierDialog();

  @override
  State<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<_AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = CreateSupplierDTO(
        name: _nameController.text.trim(),
        website: _websiteController.text.trim(),
      );

      await SuppliersApi.createSupplier(dto);

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
          String errorMessage = ErrorHandler.getContextualMessage(e, 'create-supplier');
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
                        'Dodaj dobavljača',
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
                  _DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 20),
                  _DialogTextField(
                    controller: _websiteController,
                    label: 'Web stranica (opcionalno)',
                    maxLines: 1,
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
// EDIT SUPPLEMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _EditSupplierDialog extends StatefulWidget {
  const _EditSupplierDialog({required this.supplier});

  final SupplierDTO supplier;

  @override
  State<_EditSupplierDialog> createState() => _EditSupplierDialogState();
}

class _EditSupplierDialogState extends State<_EditSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _websiteController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _websiteController = TextEditingController(text: widget.supplier.website);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dto = UpdateSupplierDTO(
        name: _nameController.text.trim(),
        website: _websiteController.text.trim(),


      );

      await SuppliersApi.updateSupplier(widget.supplier.id, dto);

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
          String errorMessage = ErrorHandler.getContextualMessage(e, 'update-supplier');
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
                        'Izmijeni dobavljača',
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
                  _DialogTextField(
                    controller: _nameController,
                    label: 'Naziv',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 20),
                  _DialogTextField(
                    controller: _websiteController,
                    label: 'Web stranica (opcionalno)',
                    maxLines: 1,
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
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
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
