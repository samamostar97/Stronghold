import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_dto.dart';
import '../services/orders_api.dart';
import '../utils/error_handler.dart';
import '../widgets/error_animation.dart';
import '../widgets/success_animation.dart';
import '../widgets/shared_admin_header.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = _Debouncer(milliseconds: 400);

  List<OrderDTO> _orders = [];
  bool _isLoading = true;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 10;

  // Sorting state
  String? _selectedOrderBy;
  bool _sortDescending = false;

  // Set of order IDs currently being marked as delivered
  final Set<int> _deliveringOrders = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadOrders();
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
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await OrdersApi.getOrders(
        search: _searchController.text.trim(),
        orderBy: _selectedOrderBy,
        descending: _sortDescending,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _orders = result.items;
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
    _loadOrders();
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() => _goToPage(_currentPage - 1);

  void _onSearch() {
    _loadOrders();
  }

  Future<void> _viewOrderDetails(OrderDTO order) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _OrderDetailsDialog(
        order: order,
        onMarkDelivered: () async {
          Navigator.of(ctx).pop();
          await _markAsDelivered(order);
        },
      ),
    );
  }

  Future<void> _markAsDelivered(OrderDTO order) async {
    if (order.status == OrderStatus.delivered) return;

    setState(() {
      _deliveringOrders.add(order.id);
    });

    try {
      await OrdersApi.markAsDelivered(order.id);
      if (mounted) {
        showSuccessAnimation(context);
      }
      _loadOrders();
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'deliver-order'),
        );
      }
    } finally {
      setState(() {
        _deliveringOrders.remove(order.id);
      });
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
            'Upravljanje narudžbama',
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
            hintText: 'Pretraži po korisniku ili email-u...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SearchInput(
            controller: _searchController,
            onSubmitted: (_) => _onSearch(),
            hintText: 'Pretraži po korisniku ili email-u...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    // Combine orderBy and descending into a single value for the dropdown
    String? dropdownValue;
    if (_selectedOrderBy != null) {
      dropdownValue = '${_selectedOrderBy}_${_sortDescending ? 'desc' : 'asc'}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: dropdownValue,
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
              value: 'date_desc',
              child: Text('Datum (najnovije)'),
            ),
            DropdownMenuItem<String?>(
              value: 'date_asc',
              child: Text('Datum (najstarije)'),
            ),
            DropdownMenuItem<String?>(
              value: 'amount_desc',
              child: Text('Iznos (opadajuće)'),
            ),
            DropdownMenuItem<String?>(
              value: 'amount_asc',
              child: Text('Iznos (rastuće)'),
            ),
            DropdownMenuItem<String?>(
              value: 'status_asc',
              child: Text('Status'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              if (value == null) {
                _selectedOrderBy = null;
                _sortDescending = false;
              } else {
                final parts = value.split('_');
                _selectedOrderBy = parts[0];
                _sortDescending = parts[1] == 'desc';
              }
              _currentPage = 1;
            });
            _loadOrders();
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
            _GradientButton(text: 'Pokušaj ponovo', onTap: _loadOrders),
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
          style: const TextStyle(color: _AppColors.muted, fontSize: 14),
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
          child: Text('...', style: TextStyle(color: _AppColors.muted)),
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
          child: Text('...', style: TextStyle(color: _AppColors.muted)),
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
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            if (_orders.isEmpty)
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
                  itemCount: _orders.length,
                  itemBuilder: (context, i) => _OrderTableRow(
                    order: _orders[i],
                    isLast: i == _orders.length - 1,
                    onViewDetails: () => _viewOrderDetails(_orders[i]),
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
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const purple = Color(0xFF9B59B6);
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

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: MouseRegion(
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
            child: const Text(
              '← Nazad',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
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
  static const int orderId = 1;
  static const int user = 3;
  static const int total = 2;
  static const int date = 2;
  static const int status = 2;
  static const int actions = 3;
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
          _HeaderCell(text: 'Narudžba #', flex: _TableFlex.orderId),
          _HeaderCell(text: 'Korisnik', flex: _TableFlex.user),
          _HeaderCell(text: 'Ukupno', flex: _TableFlex.total),
          _HeaderCell(text: 'Datum', flex: _TableFlex.date),
          _HeaderCell(text: 'Status', flex: _TableFlex.status),
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

class _OrderTableRow extends StatefulWidget {
  const _OrderTableRow({
    required this.order,
    required this.isLast,
    required this.onViewDetails,
  });

  final OrderDTO order;
  final bool isLast;
  final VoidCallback onViewDetails;

  @override
  State<_OrderTableRow> createState() => _OrderTableRowState();
}

class _OrderTableRowState extends State<_OrderTableRow> {
  bool _hover = false;

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return _AppColors.editBlue;
      case OrderStatus.delivered:
        return _AppColors.success;
    }
  }

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
            _DataCell(text: '#${widget.order.id}', flex: _TableFlex.orderId),
            Expanded(
              flex: _TableFlex.user,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.userFullName,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.order.userEmail,
                    style: const TextStyle(fontSize: 12, color: _AppColors.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _DataCell(text: _formatCurrency(widget.order.totalAmount), flex: _TableFlex.total),
            _DataCell(text: _formatDate(widget.order.purchaseDate), flex: _TableFlex.date),
            Expanded(
              flex: _TableFlex.status,
              child: _StatusBadge(
                status: widget.order.status,
                color: _getStatusColor(widget.order.status),
              ),
            ),
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _SmallButton(
                    text: 'Detalji',
                    color: _AppColors.editBlue,
                    onTap: widget.onViewDetails,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final OrderStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          status.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER DETAILS DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _OrderDetailsDialog extends StatelessWidget {
  const _OrderDetailsDialog({
    required this.order,
    required this.onMarkDelivered,
  });

  final OrderDTO order;
  final VoidCallback onMarkDelivered;

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return _AppColors.editBlue;
      case OrderStatus.delivered:
        return _AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canMarkDelivered = order.status != OrderStatus.delivered;

    return Dialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Narudžba #${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _StatusBadge(
                    status: order.status,
                    color: _getStatusColor(order.status),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: _AppColors.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _AppColors.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Korisnik', value: order.userFullName),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Email', value: order.userEmail),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Datum narudžbe', value: _formatDate(order.purchaseDate)),
                    if (order.stripePaymentId != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(label: 'ID plaćanja', value: order.stripePaymentId!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Order items header
              const Text(
                'Stavke narudžbe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Order items table
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: _AppColors.panel,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Items header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: _AppColors.border)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 4, child: Text('Proizvod', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                            Expanded(flex: 1, child: Text('Kol.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text('Cijena', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
                            Expanded(flex: 2, child: Text('Ukupno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      // Items list
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: order.orderItems.length,
                          itemBuilder: (context, index) {
                            final item = order.orderItems[index];
                            final isLast = index == order.orderItems.length - 1;
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                border: isLast ? null : const Border(bottom: BorderSide(color: _AppColors.border)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.supplementName,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatCurrency(item.unitPrice),
                                      style: const TextStyle(color: _AppColors.muted, fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatCurrency(item.totalPrice),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Total row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: _AppColors.border, width: 2)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(flex: 7, child: Text('Ukupno za platiti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatCurrency(order.totalAmount),
                                style: const TextStyle(
                                  color: _AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Zatvori', style: TextStyle(color: _AppColors.muted)),
                  ),
                  if (canMarkDelivered) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onMarkDelivered,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Označi kao dostavljeno'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: _AppColors.muted, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
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
            color: _hover && isEnabled ? _AppColors.accent : _AppColors.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _AppColors.border),
          ),
          child: Icon(
            widget.icon,
            color: isEnabled ? Colors.white : _AppColors.muted,
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
                ? _AppColors.accent
                : _hover
                    ? _AppColors.panel
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive ? null : Border.all(color: _AppColors.border),
          ),
          child: Center(
            child: Text(
              '${widget.page}',
              style: TextStyle(
                color: widget.isActive ? Colors.white : _AppColors.muted,
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
