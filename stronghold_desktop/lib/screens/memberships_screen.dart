import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/user_provider.dart';
import '../providers/membership_provider.dart';
import '../providers/membership_package_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/back_button.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/gradient_button.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/search_input.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/shared_admin_header.dart';
import '../widgets/shimmer_loading.dart';
import 'payment_history_screen.dart';

/// Refactored Membership Management Screen using Riverpod
class MembershipsScreen extends ConsumerStatefulWidget {
  const MembershipsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends ConsumerState<MembershipsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String? query) {
    ref.read(userListProvider.notifier).setSearch(query ?? '');
  }

  void _goToPage(int page) {
    ref.read(userListProvider.notifier).goToPage(page);
  }

  void _viewPayments(UserResponse user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(user: user),
      ),
    );
  }

  Future<void> _addPayment(UserResponse user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _AddPaymentDialog(user: user),
    );

    if (result == true && mounted) {
      showSuccessAnimation(context);
      // Invalidate the active membership status for this user
      ref.invalidate(userHasActiveMembershipProvider(user.id));
      // Invalidate payment history cache so it's fresh when viewed
      ref.invalidate(userPaymentsProvider(UserPaymentsParams(
        userId: user.id,
        filter: MembershipQueryFilter(pageSize: 10),
      )));
    }
  }

  Future<void> _revokeMembership(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmRevokeDialog(user: user),
    );

    if (confirmed == true) {
      try {
        await ref.read(membershipOperationsProvider.notifier).revokeMembership(user.id);
        if (mounted) {
          showSuccessAnimation(context);
          // Invalidate the active membership status
          ref.invalidate(userHasActiveMembershipProvider(user.id));
        }
      } catch (e) {
        if (mounted) {
          showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'revoke-membership'));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);

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
            child: _buildMainContent(constraints, state),
          );
        },
      );
    }

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
                    Expanded(child: _buildMainContent(constraints, state)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints, userState) {
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
          SearchInput(
            controller: _searchController,
            onSubmitted: _onSearch,
            hintText: 'Pretraži po imenu, prezimenu ili korisničkom imenu...',
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(constraints, userState)),
        ],
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints, userState) {
    if (userState.isLoading) {
      return const ShimmerTable(columnFlex: [2, 2, 2, 3, 4]);
    }

    if (userState.error != null) {
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
              userState.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Pokušaj ponovo',
              onTap: () => ref.read(userListProvider.notifier).load(),
            ),
          ],
        ),
      );
    }

    final users = userState.data?.items ?? <UserResponse>[];
    final totalPages = userState.data?.totalPages(userState.filter.pageSize) ?? 1;
    final totalCount = userState.data?.totalCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _MembershipsTable(
            users: users,
            onViewPayments: _viewPayments,
            onAddPayment: _addPayment,
            onRevokeMembership: _revokeMembership,
          ),
        ),
        const SizedBox(height: 16),
        PaginationControls(
          currentPage: userState.filter.pageNumber,
          totalPages: totalPages,
          totalCount: totalCount,
          onPageChanged: _goToPage,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int username = 2;
  static const int firstName = 2;
  static const int lastName = 2;
  static const int email = 3;
  static const int actions = 4;
}

class _MembershipsTable extends StatelessWidget {
  const _MembershipsTable({
    required this.users,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevokeMembership,
  });

  final List<UserResponse> users;
  final ValueChanged<UserResponse> onViewPayments;
  final ValueChanged<UserResponse> onAddPayment;
  final ValueChanged<UserResponse> onRevokeMembership;

  @override
  Widget build(BuildContext context) {
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
            if (users.isEmpty)
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
                  itemCount: users.length,
                  itemBuilder: (context, i) => _UserTableRow(
                    user: users[i],
                    index: i,
                    isLast: i == users.length - 1,
                    onViewPayments: () => onViewPayments(users[i]),
                    onAddPayment: () => onAddPayment(users[i]),
                    onRevokeMembership: () => onRevokeMembership(users[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: const Row(
        children: [
          TableHeaderCell(text: 'Korisničko ime', flex: _TableFlex.username),
          TableHeaderCell(text: 'Ime', flex: _TableFlex.firstName),
          TableHeaderCell(text: 'Prezime', flex: _TableFlex.lastName),
          TableHeaderCell(text: 'Email', flex: _TableFlex.email),
          TableHeaderCell(text: 'Akcije', flex: _TableFlex.actions, alignRight: true),
        ],
      ),
    );
  }
}

class _UserTableRow extends ConsumerWidget {
  const _UserTableRow({
    required this.user,
    required this.index,
    required this.isLast,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevokeMembership,
  });

  final UserResponse user;
  final int index;
  final bool isLast;
  final VoidCallback onViewPayments;
  final VoidCallback onAddPayment;
  final VoidCallback onRevokeMembership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMembershipAsync = ref.watch(userHasActiveMembershipProvider(user.id));

    // Hide green indicator immediately when provider is refetching
    // (after invalidation). Riverpod preserves previous data during
    // reload, so we must also check isLoading.
    final isActive = !activeMembershipAsync.isLoading &&
        (activeMembershipAsync.valueOrNull == true);

    return HoverableTableRow(
      isLast: isLast,
      index: index,
      activeAccentColor: isActive ? AppColors.success : null,
      child: Row(
        children: [
          TableDataCell(text: user.username, flex: _TableFlex.username),
          Expanded(
            flex: _TableFlex.firstName,
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (activeMembershipAsync.isLoading)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    child: const CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.muted),
                  ),
                Flexible(
                  child: Text(
                    user.firstName,
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          TableDataCell(text: user.lastName, flex: _TableFlex.lastName),
          TableDataCell(text: user.email, flex: _TableFlex.email, muted: true),
          TableActionCell(
            flex: _TableFlex.actions,
            children: [
              SmallButton(
                text: 'Pregled uplata',
                color: AppColors.editBlue,
                onTap: onViewPayments,
              ),
              const SizedBox(width: 8),
              SmallButton(
                text: 'Dodaj uplatu',
                color: AppColors.accent,
                onTap: onAddPayment,
              ),
              const SizedBox(width: 8),
              SmallButton(
                text: 'Ukini članarinu',
                color: Colors.red,
                onTap: onRevokeMembership,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD PAYMENT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AddPaymentDialog extends ConsumerStatefulWidget {
  const _AddPaymentDialog({required this.user});

  final UserResponse user;

  @override
  ConsumerState<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<_AddPaymentDialog> {
  MembershipPackageResponse? _selectedPackage;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  String? _errorMessage;

  final _dateFormat = DateFormat('dd.MM.yyyy.');

  @override
  void initState() {
    super.initState();
    // Load membership packages when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipPackageListProvider.notifier).load();
    });
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
      final request = AssignMembershipRequest(
        userId: widget.user.id,
        membershipPackageId: _selectedPackage!.id,
        amountPaid: _selectedPackage!.packagePrice,
        paymentDate: _startDate!,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      await ref.read(membershipOperationsProvider.notifier).assignMembership(request);

      if (mounted) {
        Navigator.of(context).pop(true);
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
    final packagesAsync = ref.watch(membershipPackageListProvider);

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
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Builder(builder: (_) {
                  if (packagesAsync.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    );
                  }
                  if (packagesAsync.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Greška: ${packagesAsync.error}', style: const TextStyle(color: AppColors.accent)),
                      ),
                    );
                  }
                  final packages = packagesAsync.data?.items ?? <MembershipPackageResponse>[];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            child: DropdownButton<MembershipPackageResponse>(
                              value: _selectedPackage,
                              hint: const Text(
                                'Odaberite paket',
                                style: TextStyle(color: AppColors.muted),
                              ),
                              isExpanded: true,
                              dropdownColor: AppColors.panel,
                              items: packages.map((pkg) {
                                return DropdownMenuItem(
                                  value: pkg,
                                  child: Text(
                                    '${pkg.packageName ?? 'N/A'} - ${pkg.packagePrice.toStringAsFixed(2)} KM',
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
                                const Icon(Icons.error_outline, color: AppColors.accent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppColors.accent, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Dodaj uplatu',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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

  final UserResponse user;

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
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 56),
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
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Ne', style: TextStyle(color: AppColors.muted, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Da, ukini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
