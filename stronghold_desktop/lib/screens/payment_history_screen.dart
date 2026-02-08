import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/membership_provider.dart';
import '../widgets/back_button.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/shared_admin_header.dart';

/// Payment History Screen - shows all payments for a specific user
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key, required this.user});

  final UserResponse user;

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _dateFormat = DateFormat('dd.MM.yyyy.');
  MembershipQueryFilter _filter = MembershipQueryFilter(pageSize: 10);

  UserPaymentsParams get _params => UserPaymentsParams(
        userId: widget.user.id,
        filter: _filter,
      );

  @override
  void initState() {
    super.initState();
    // Invalidate cached data to ensure fresh fetch when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userPaymentsProvider(_params));
    });
  }

  void _goToPage(int page) {
    setState(() {
      _filter = _filter.copyWith(pageNumber: page);
    });
    ref.invalidate(userPaymentsProvider(_params));
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(userPaymentsProvider(_params));

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
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Historija uplata',
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 28 : 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _UserInfoCard(user: widget.user),
                            const SizedBox(height: 24),
                            Expanded(
                              child: paymentsAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(color: AppColors.accent),
                                ),
                                error: (e, _) => Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Greška pri učitavanju',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        e.toString(),
                                        style: const TextStyle(color: AppColors.muted, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      GradientButton(
                                        text: 'Pokušaj ponovo',
                                        onTap: () => ref.invalidate(userPaymentsProvider(_params)),
                                      ),
                                    ],
                                  ),
                                ),
                                data: (pagedResult) {
                                  final payments = pagedResult.items;
                                  final totalPages = pagedResult.totalPages(_filter.pageSize);
                                  final totalCount = pagedResult.totalCount;

                                  return Column(
                                    children: [
                                      Expanded(
                                        child: _PaymentsTable(
                                          payments: payments,
                                          dateFormat: _dateFormat,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      PaginationControls(
                                        currentPage: _filter.pageNumber,
                                        totalPages: totalPages,
                                        totalCount: totalCount,
                                        onPageChanged: _goToPage,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.accent, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '@${user.username}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Text(
            user.email,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENTS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int packageName = 3;
  static const int amount = 2;
  static const int paymentDate = 2;
  static const int startDate = 2;
  static const int endDate = 2;
  static const int status = 2;
}

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({
    required this.payments,
    required this.dateFormat,
  });

  final List<MembershipPaymentResponse> payments;
  final DateFormat dateFormat;

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
            if (payments.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Nema uplata za ovog korisnika.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, i) => _PaymentRow(
                    payment: payments[i],
                    isLast: i == payments.length - 1,
                    dateFormat: dateFormat,
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          TableHeaderCell(text: 'Vrsta članarine', flex: _TableFlex.packageName),
          TableHeaderCell(text: 'Iznos', flex: _TableFlex.amount),
          TableHeaderCell(text: 'Datum uplate', flex: _TableFlex.paymentDate),
          TableHeaderCell(text: 'Početak', flex: _TableFlex.startDate),
          TableHeaderCell(text: 'Kraj', flex: _TableFlex.endDate),
          TableHeaderCell(text: 'Status', flex: _TableFlex.status),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.isLast,
    required this.dateFormat,
  });

  final MembershipPaymentResponse payment;
  final bool isLast;
  final DateFormat dateFormat;

  bool get _isActive => payment.endDate.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      child: Row(
        children: [
          TableDataCell(text: payment.packageName, flex: _TableFlex.packageName),
          TableDataCell(
            text: '${payment.amountPaid.toStringAsFixed(2)} KM',
            flex: _TableFlex.amount,
          ),
          TableDataCell(
            text: dateFormat.format(payment.paymentDate),
            flex: _TableFlex.paymentDate,
          ),
          TableDataCell(
            text: dateFormat.format(payment.startDate),
            flex: _TableFlex.startDate,
          ),
          TableDataCell(
            text: dateFormat.format(payment.endDate),
            flex: _TableFlex.endDate,
          ),
          Expanded(
            flex: _TableFlex.status,
            child: _isActive ? const _ActiveBadge() : const _ExpiredBadge(),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: const Text(
        'AKTIVNA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4CAF50),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.muted.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: const Text(
        'ISTEKLA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
