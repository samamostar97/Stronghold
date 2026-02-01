import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_desktop/models/membership_package_dto.dart';
import '../constants/app_colors.dart';
import '../models/user_dto.dart';
import '../services/users_api.dart';
import '../services/memberships_api.dart';
import '../utils/debouncer.dart';
import '../widgets/back_button.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';
import '../utils/error_handler.dart';
import 'membership_payment_history_screen.dart';

class MembershipManagementScreen extends StatefulWidget {
  const MembershipManagementScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MembershipManagementScreen> createState() => _MembershipManagementScreenState();
}

class _MembershipManagementScreenState extends State<MembershipManagementScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

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
    // Embedded mode: just return the content without Scaffold/gradient/header
    if (widget.embedded) {
      return LayoutBuilder(
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
            child: _buildMainContent(constraints),
          );
        },
      );
    }

    // Standalone mode: full Scaffold with gradient
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
    return SearchInput(
      controller: _searchController,
      onSubmitted: (_) => _onSearch(),
      hintText: 'Pretraži po imenu, prezimenu ili korisničkom imenu...',
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
              style: TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokušaj ponovo', onTap: _loadUsers),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildTable(constraints)),
        const SizedBox(height: 16),
        PaginationControls(currentPage: _currentPage, totalPages: _totalPages, totalCount: _totalCount, onPageChanged: _goToPage),
      ],
    );
  }

  Widget _buildTable(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 800;
    final tableMinWidth = isNarrow ? 750.0 : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
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
  static const int actions = 4;
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
      child: Row(
        children: [
          _HeaderCell(text: 'Korisničko ime', flex: _TableFlex.username),
          _HeaderCell(text: 'Ime', flex: _TableFlex.firstName),
          _HeaderCell(text: 'Prezime', flex: _TableFlex.lastName),
          _HeaderCell(text: 'Email', flex: _TableFlex.email),
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
          color: _hover ? AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
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
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
            _DataCell(text: widget.user.lastName, flex: _TableFlex.lastName),
            _DataCell(text: widget.user.email, flex: _TableFlex.email),
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SmallButton(
                      text: 'Pregled uplata',
                      color: AppColors.editBlue,
                      onTap: widget.onViewPayments,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: SmallButton(
                      text: 'Dodaj uplatu',
                      color: AppColors.accent,
                      onTap: widget.onAddPayment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: SmallButton(
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
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.card,
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
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.card,
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
      backgroundColor: AppColors.card,
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
                      icon: const Icon(Icons.close, color: AppColors.muted),
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
                    color: AppColors.panel,
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
                          color: AppColors.muted,
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
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Greška: $_error',
                        style: const TextStyle(color: AppColors.accent),
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
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MembershipPackageDTO>(
                        value: _selectedPackage,
                        hint: const Text(
                          'Odaberite paket',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        isExpanded: true,
                        dropdownColor: AppColors.panel,
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
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _startDate != null
                                  ? _dateFormat.format(_startDate!)
                                  : 'Odaberite datum',
                              style: TextStyle(
                                color: _startDate != null ? Colors.white : AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.muted, size: 20),
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
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _endDate != null
                                  ? _dateFormat.format(_endDate!)
                                  : 'Odaberite datum',
                              style: TextStyle(
                                color: _endDate != null ? Colors.white : AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.muted, size: 20),
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
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.accent,
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
                            : AppColors.accent,
                        disabledBackgroundColor: _isSuccess
                            ? const Color(0xFF4CAF50)
                            : AppColors.accent.withValues(alpha: 0.5),
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
      backgroundColor: AppColors.card,
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
                color: AppColors.muted,
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
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
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
