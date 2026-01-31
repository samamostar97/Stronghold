import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_desktop/models/membership_package_dto.dart';
import '../models/user_dto.dart';
import '../services/users_api.dart';
import '../services/memberships_api.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';
import '../utils/error_handler.dart';
import 'membership_payment_history_screen.dart';

class MembershipManagementScreen extends StatefulWidget {
  const MembershipManagementScreen({super.key});

  @override
  State<MembershipManagementScreen> createState() => _MembershipManagementScreenState();
}

class _MembershipManagementScreenState extends State<MembershipManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = _Debouncer(milliseconds: 400);

  List<UserTableRowDTO> _users = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  static const int _pageSize = 10;

  // Membership status tracking
  final Map<int, bool> _activeMembershipStatus = {};
  Set<int> _loadingStatuses = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUsers();
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
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await UsersApi.getUsers(
        search: _searchController.text.trim(),
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _users = result.items;
        _totalPages = result.totalPages;
        _totalCount = result.totalCount;
        _isLoading = false;
      });

      // Load membership statuses after users are loaded
      _loadMembershipStatuses();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkActiveMembership(int userId) async {
    try {
      final result = await MembershipsApi.getUserPayments(
        userId,
        pageNumber: 1,
        pageSize: 10,
      );

      // Check if any payment has endDate > today
      final now = DateTime.now();
      return result.items.any((payment) => payment.endDate.isAfter(now));
    } catch (e) {
      return false; // Silent failure - show no badge on error
    }
  }

  Future<void> _loadMembershipStatuses() async {
    setState(() {
      _loadingStatuses = _users.map((u) => u.id).toSet();
    });

    await Future.wait(
      _users.map((user) async {
        final isActive = await _checkActiveMembership(user.id);
        if (mounted) {
          setState(() {
            _activeMembershipStatus[user.id] = isActive;
            _loadingStatuses.remove(user.id);
          });
        }
      }),
    );
  }

  void _onSearch() {
    _currentPage = 1;
    _loadUsers();
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    _loadUsers();
  }

  void _viewPayments(UserTableRowDTO user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberPaymentHistoryScreen(user: user),
      ),
    );
  }

  Future<void> _revokeMembership(UserTableRowDTO user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmRevokeDialog(user: user),
    );

    if (confirmed == true) {
      try {
        await MembershipsApi.revokeMembership(user.id);
        if (mounted) {
          // Immediately mark as inactive
          setState(() {
            _activeMembershipStatus[user.id] = false;
          });

          _showSuccessAnimation();
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = ErrorHandler.getContextualMessage(e, 'revoke-membership');
          showErrorAnimation(context, message: errorMessage);
        }
      }
    }
  }

  void _showSuccessAnimation() {
    showSuccessAnimation(context);
  }

  Future<void> _addPayment(UserTableRowDTO user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AddPaymentDialog(user: user),
    );

    if (result == true && mounted) {
      // Payment was added successfully, show success animation
      showSuccessAnimation(context);

      // Refresh the list
      _loadUsers();

      // Update status for this specific user
      final isActive = await _checkActiveMembership(user.id);
      if (mounted) {
        setState(() {
          _activeMembershipStatus[user.id] = isActive;
        });
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
            'Upravljanje članarinama',
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
    return _SearchInput(
      controller: _searchController,
      onSubmitted: (_) => _onSearch(),
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
              style: TextStyle(color: _AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _GradientButton(text: 'Pokušaj ponovo', onTap: _loadUsers),
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

  Widget _buildTable(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 800;
    final tableMinWidth = isNarrow ? 750.0 : null;

    return Container(
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNarrow
            ? LayoutBuilder(
                builder: (context, innerConstraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableMinWidth,
                      height: innerConstraints.maxHeight,
                      child: Column(
                        children: [
                          const _TableHeader(),
                          if (_users.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Nema rezultata.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, i) => _UserTableRow(
                                  user: _users[i],
                                  isLast: i == _users.length - 1,
                                  hasActiveMembership: _activeMembershipStatus[_users[i].id] ?? false,
                                  isLoadingStatus: _loadingStatuses.contains(_users[i].id),
                                  onViewPayments: () => _viewPayments(_users[i]),
                                  onAddPayment: () => _addPayment(_users[i]),
                                  onRevokeMembership: () => _revokeMembership(_users[i]),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Column(
                children: [
                  const _TableHeader(),
                  if (_users.isEmpty)
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
                        itemCount: _users.length,
                        itemBuilder: (context, i) => _UserTableRow(
                          user: _users[i],
                          isLast: i == _users.length - 1,
                          hasActiveMembership: _activeMembershipStatus[_users[i].id] ?? false,
                          isLoadingStatus: _loadingStatuses.contains(_users[i].id),
                          onViewPayments: () => _viewPayments(_users[i]),
                          onAddPayment: () => _addPayment(_users[i]),
                          onRevokeMembership: () => _revokeMembership(_users[i]),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaginationControls() {
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
              onTap: () => _goToPage(_currentPage - 1),
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
            _PaginationButton(
              text: '→',
              enabled: _currentPage < _totalPages,
              onTap: () => _goToPage(_currentPage + 1),
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
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Pretraži po imenu, prezimenu ili korisničkom imenu...',
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// Column flex values for responsive table layout
abstract class _TableFlex {
  static const int username = 2;
  static const int firstName = 2;
  static const int lastName = 2;
  static const int email = 3;
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
      child: Row(
        children: [
          _HeaderCell(text: 'Korisničko ime', flex: _TableFlex.username),
          _HeaderCell(text: 'Ime', flex: _TableFlex.firstName),
          _HeaderCell(text: 'Prezime', flex: _TableFlex.lastName),
          _HeaderCell(text: 'Email', flex: _TableFlex.email),
          _HeaderCell(text: 'Telefon', flex: _TableFlex.phone),
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

class _UserTableRow extends StatefulWidget {
  const _UserTableRow({
    required this.user,
    required this.isLast,
    required this.hasActiveMembership,
    required this.isLoadingStatus,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevokeMembership,
  });

  final UserTableRowDTO user;
  final bool isLast;
  final bool hasActiveMembership;
  final bool isLoadingStatus;
  final VoidCallback onViewPayments;
  final VoidCallback onAddPayment;
  final VoidCallback onRevokeMembership;

  @override
  State<_UserTableRow> createState() => _UserTableRowState();
}

class _UserTableRowState extends State<_UserTableRow> {
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
            _DataCell(text: widget.user.username, flex: _TableFlex.username),
            Expanded(
              flex: _TableFlex.firstName,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.user.firstName,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (widget.hasActiveMembership)
                    const _ActiveBadge(),
                  if (widget.isLoadingStatus)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 12,
                      height: 12,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
            _DataCell(text: widget.user.lastName, flex: _TableFlex.lastName),
            _DataCell(text: widget.user.email, flex: _TableFlex.email),
            _DataCell(text: widget.user.phoneNumber, flex: _TableFlex.phone),
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _SmallButton(
                      text: 'Pregled uplata',
                      color: _AppColors.editBlue,
                      onTap: widget.onViewPayments,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _SmallButton(
                      text: 'Dodaj uplatu',
                      color: _AppColors.accent,
                      onTap: widget.onAddPayment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _SmallButton(
                      text: 'Ukini članarinu',
                      color: Colors.red,
                      onTap: widget.onRevokeMembership,
                    ),
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
        maxLines: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATION WIDGETS
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
// ADD PAYMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddPaymentDialog extends StatefulWidget {
  const _AddPaymentDialog({required this.user});

  final UserTableRowDTO user;

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  List<MembershipPackageDTO> _packages = [];
  MembershipPackageDTO? _selectedPackage;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSuccess = false;
  String? _error;
  String? _errorMessage;

  final _dateFormat = DateFormat('dd.MM.yyyy.');

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await MembershipsApi.getPackages();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _AppColors.accent,
              onPrimary: Colors.white,
              surface: _AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _AppColors.accent,
              onPrimary: Colors.white,
              surface: _AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submit() async {
    // Validate selections
    if (_selectedPackage == null) {
      setState(() => _errorMessage = 'Molimo odaberite vrstu članarine');
      return;
    }
    if (_startDate == null) {
      setState(() => _errorMessage = 'Molimo odaberite početak članarine');
      return;
    }
    if (_endDate == null) {
      setState(() => _errorMessage = 'Molimo odaberite kraj članarine');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _errorMessage = 'Kraj članarine mora biti nakon početka članarine');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final request = AddMembershipPaymentRequest(
        userId: widget.user.id,
        membershipPackageId: _selectedPackage!.id,
        amountPaid: _selectedPackage!.packagePrice,
        paymentDate: _startDate!,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      await MembershipsApi.assignMembership(request);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSuccess = true;
        });

        // Wait to show success state, then close
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = ErrorHandler.getContextualMessage(e, 'add-payment');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with close button
                Row(
                  children: [
                    const Text(
                      'Dodaj uplatu',
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
                const SizedBox(height: 4),
                Text(
                  'Unesite detalje nove uplate za člana',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // User info display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _AppColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${widget.user.username}',
                        style: const TextStyle(
                          color: _AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Loading/Error state for packages
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: _AppColors.accent),
                    ),
                  )
                else if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Greška: $_error',
                        style: const TextStyle(color: _AppColors.accent),
                      ),
                    ),
                  )
                else ...[
                  // Membership type dropdown
                  const Text(
                    'Vrsta članarine :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _AppColors.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MembershipPackageDTO>(
                        value: _selectedPackage,
                        hint: const Text(
                          'Odaberite paket',
                          style: TextStyle(color: _AppColors.muted),
                        ),
                        isExpanded: true,
                        dropdownColor: _AppColors.panel,
                        items: _packages.map((pkg) {
                          return DropdownMenuItem(
                            value: pkg,
                            child: Text(
                              '${pkg.packageName} - ${pkg.packagePrice.toStringAsFixed(2)} KM',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPackage = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Start date picker
                  const Text(
                    'Početak članarine :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _startDate != null
                                  ? _dateFormat.format(_startDate!)
                                  : 'Odaberite datum',
                              style: TextStyle(
                                color: _startDate != null ? Colors.white : _AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: _AppColors.muted, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // End date picker
                  const Text(
                    'Kraj članarine :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _endDate != null
                                  ? _dateFormat.format(_endDate!)
                                  : 'Odaberite datum',
                              style: TextStyle(
                                color: _endDate != null ? Colors.white : _AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: _AppColors.muted, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error message display
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: _AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: _AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSaving || _isSuccess) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSuccess
                            ? const Color(0xFF4CAF50)
                            : _AppColors.accent,
                        disabledBackgroundColor: _isSuccess
                            ? const Color(0xFF4CAF50)
                            : _AppColors.accent.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSuccess
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'USPJEŠNO!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Dodaj uplatu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE MEMBERSHIP BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: const Text(
        'AKTIVAN',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4CAF50),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM REVOKE DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmRevokeDialog extends StatelessWidget {
  const _ConfirmRevokeDialog({required this.user});

  final UserTableRowDTO user;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ukini članarinu?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Da li ste sigurni da želite ukinuti članarinu za korisnika ${user.firstName} ${user.lastName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AppColors.muted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Ne',
                    style: TextStyle(color: _AppColors.muted, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Da, ukini',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
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
