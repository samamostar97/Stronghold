import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/membership_provider.dart';
import '../shared/data_table_widgets.dart';
import '../shared/pagination_controls.dart';

class UserPaymentsTab extends ConsumerStatefulWidget {
  const UserPaymentsTab({super.key, required this.userId});

  final int userId;

  @override
  ConsumerState<UserPaymentsTab> createState() => _UserPaymentsTabState();
}

class _UserPaymentsTabState extends ConsumerState<UserPaymentsTab> {
  final _dateFormat = DateFormat('dd.MM.yyyy.');
  MembershipQueryFilter _filter = MembershipQueryFilter(pageSize: 10);

  UserPaymentsParams get _params =>
      UserPaymentsParams(userId: widget.userId, filter: _filter);

  void _goToPage(int page) {
    setState(() {
      _filter = _filter.copyWith(pageNumber: page);
    });
    ref.invalidate(userPaymentsProvider(_params));
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(userPaymentsProvider(_params));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: paymentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electric),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Greska pri ucitavanju uplata',
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(e.toString(), style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () =>
                    ref.invalidate(userPaymentsProvider(_params)),
                child: Text('Pokusaj ponovo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.electric)),
              ),
            ],
          ),
        ),
        data: (pagedResult) {
          final payments = pagedResult.items;
          final totalPages = pagedResult.totalPages(_filter.pageSize);

          if (payments.isEmpty) {
            return Center(
              child: Text(
                'Korisnik nema uplata za clanarinu.',
                style: AppTextStyles.bodySecondary,
              ),
            );
          }

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
                totalCount: pagedResult.totalCount,
                onPageChanged: _goToPage,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENTS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
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
            TableHeaderCell(text: 'Vrsta clanarine', flex: _Flex.packageName),
            TableHeaderCell(text: 'Iznos', flex: _Flex.amount),
            TableHeaderCell(text: 'Datum uplate', flex: _Flex.paymentDate),
            TableHeaderCell(text: 'Pocetak', flex: _Flex.startDate),
            TableHeaderCell(text: 'Kraj', flex: _Flex.endDate),
            TableHeaderCell(text: 'Status', flex: _Flex.status),
          ],
        ),
      ),
      itemCount: payments.length,
      itemBuilder: (context, i) {
        final payment = payments[i];
        final isActive = payment.endDate.isAfter(DateTime.now());

        return HoverableTableRow(
          index: i,
          isLast: i == payments.length - 1,
          child: Row(
            children: [
              TableDataCell(
                  text: payment.packageName, flex: _Flex.packageName),
              TableDataCell(
                text: '${payment.amountPaid.toStringAsFixed(2)} KM',
                flex: _Flex.amount,
              ),
              TableDataCell(
                text: dateFormat.format(payment.paymentDate),
                flex: _Flex.paymentDate,
              ),
              TableDataCell(
                text: dateFormat.format(payment.startDate),
                flex: _Flex.startDate,
              ),
              TableDataCell(
                text: dateFormat.format(payment.endDate),
                flex: _Flex.endDate,
              ),
              Expanded(
                flex: _Flex.status,
                child:
                    isActive ? const _ActiveBadge() : const _ExpiredBadge(),
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
