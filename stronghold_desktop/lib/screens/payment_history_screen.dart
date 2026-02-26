import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/membership_provider.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/pagination_controls.dart';

/// Payment History Screen - shows all payments for a specific user
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key, required this.user});

  final UserResponse user;

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _dateFormat = DateFormat('dd.MM.yyyy.');
  MembershipQueryFilter _filter = MembershipQueryFilter(pageSize: 10);
  String? _selectedOrderBy;

  UserPaymentsParams get _params =>
      UserPaymentsParams(userId: widget.user.id, filter: _filter);

  @override
  void initState() {
    super.initState();
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

  void _setOrderBy(String? orderBy) {
    final normalizedOrderBy = orderBy ?? '';
    setState(() {
      _selectedOrderBy = orderBy;
      _filter = _filter.copyWith(pageNumber: 1, orderBy: normalizedOrderBy);
    });
    ref.invalidate(userPaymentsProvider(_params));
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(userPaymentsProvider(_params));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final pad = w > 1200
              ? 40.0
              : w > 800
              ? 24.0
              : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pad,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _backButton()
                    .animate()
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.55),
                      borderRadius: AppSpacing.cardRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _UserInfoCard(user: widget.user),
                        const SizedBox(height: AppSpacing.lg),
                        _sortDropdown(),
                        const SizedBox(height: AppSpacing.xxl),
                        Expanded(
                          child: paymentsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                            error: (e, _) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Greska pri ucitavanju',
                                    style: AppTextStyles.cardTitle,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    e.toString(),
                                    style: AppTextStyles.bodySecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  GradientButton.text(
                                    text: 'Pokusaj ponovo',
                                    onPressed: () => ref.invalidate(
                                      userPaymentsProvider(_params),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            data: (pagedResult) {
                              final payments = pagedResult.items;
                              final totalPages = pagedResult.totalPages(
                                _filter.pageSize,
                              );
                              final totalCount = pagedResult.totalCount;

                              return Column(
                                children: [
                                  Expanded(
                                    child: _PaymentsTable(
                                      payments: payments,
                                      dateFormat: _dateFormat,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
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
    );
  }

  Widget _sortDropdown() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.smallRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: _selectedOrderBy,
            hint: Text('Sortiraj', style: AppTextStyles.bodySecondary),
            dropdownColor: AppColors.surface,
            style: AppTextStyles.bodyMedium,
            icon: Icon(
              LucideIcons.arrowUpDown,
              color: AppColors.textMuted,
              size: 16,
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Zadano')),
              DropdownMenuItem(
                value: 'datedesc',
                child: Text('Datum uplate (najnovije)'),
              ),
              DropdownMenuItem(
                value: 'date',
                child: Text('Datum uplate (najstarije)'),
              ),
              DropdownMenuItem(
                value: 'amountdesc',
                child: Text('Iznos (opadajuce)'),
              ),
              DropdownMenuItem(value: 'amount', child: Text('Iznos (rastuce)')),
            ],
            onChanged: _setOrderBy,
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary),
        label: Text(
          'Nazad na clanarine',
          style: AppTextStyles.bodySecondary.copyWith(color: AppColors.primary),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.buttonRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.user, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text('@${user.username}', style: AppTextStyles.bodySm),
            ],
          ),
          const Spacer(),
          Text(user.email, style: AppTextStyles.bodySm),
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
  const _PaymentsTable({required this.payments, required this.dateFormat});

  final List<MembershipPaymentResponse> payments;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(
          children: [
            TableHeaderCell(
              text: 'Vrsta clanarine',
              flex: _TableFlex.packageName,
            ),
            TableHeaderCell(text: 'Iznos', flex: _TableFlex.amount),
            TableHeaderCell(text: 'Datum uplate', flex: _TableFlex.paymentDate),
            TableHeaderCell(text: 'Pocetak', flex: _TableFlex.startDate),
            TableHeaderCell(text: 'Kraj', flex: _TableFlex.endDate),
            TableHeaderCell(text: 'Status', flex: _TableFlex.status),
          ],
        ),
      ),
      itemCount: payments.length,
      emptyMessage: 'Nema uplata za ovog korisnika.',
      itemBuilder: (context, i) {
        final payment = payments[i];
        final isActive = payment.endDate.isAfter(DateTime.now());
        return HoverableTableRow(
          index: i,
          isLast: i == payments.length - 1,
          child: Row(
            children: [
              TableDataCell(
                text: payment.packageName,
                flex: _TableFlex.packageName,
              ),
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
                child: isActive ? const _ActiveBadge() : const _ExpiredBadge(),
              ),
            ],
          ),
        );
      },
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
        color: AppColors.successDim,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: Text(
        'AKTIVNA',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
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
        color: AppColors.textMuted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.5)),
      ),
      child: Text(
        'ISTEKLA',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
