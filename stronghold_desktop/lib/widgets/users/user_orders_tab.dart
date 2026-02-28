import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/user_profile_provider.dart';
import '../shared/data_table_widgets.dart';
import '../shared/pagination_controls.dart';

class UserOrdersTab extends ConsumerStatefulWidget {
  const UserOrdersTab({super.key, required this.userId});

  final int userId;

  @override
  ConsumerState<UserOrdersTab> createState() => _UserOrdersTabState();
}

class _UserOrdersTabState extends ConsumerState<UserOrdersTab> {
  final _dateFormat = DateFormat('dd.MM.yyyy.');
  int _page = 1;
  static const _pageSize = 10;

  UserOrdersParams get _params => UserOrdersParams(
        userId: widget.userId,
        pageNumber: _page,
        pageSize: _pageSize,
      );

  void _goToPage(int page) {
    setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersProvider(_params));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electric),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Greska pri ucitavanju narudzbi',
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(e.toString(), style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () =>
                    ref.invalidate(userOrdersProvider(_params)),
                child: Text('Pokusaj ponovo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.electric)),
              ),
            ],
          ),
        ),
        data: (pagedResult) {
          final orders = pagedResult.items;
          final totalPages = pagedResult.totalPages(_pageSize);

          if (orders.isEmpty) {
            return Center(
              child: Text(
                'Korisnik nema narudzbi.',
                style: AppTextStyles.bodySecondary,
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _OrdersTable(
                  orders: orders,
                  dateFormat: _dateFormat,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PaginationControls(
                currentPage: _page,
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
// ORDERS TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
  static const int id = 1;
  static const int date = 2;
  static const int items = 3;
  static const int total = 2;
  static const int status = 2;
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders, required this.dateFormat});

  final List<OrderResponse> orders;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(
          children: [
            TableHeaderCell(text: '#', flex: _Flex.id),
            TableHeaderCell(text: 'Datum', flex: _Flex.date),
            TableHeaderCell(text: 'Stavke', flex: _Flex.items),
            TableHeaderCell(text: 'Ukupno', flex: _Flex.total),
            TableHeaderCell(text: 'Status', flex: _Flex.status),
          ],
        ),
      ),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        final statusDisplay = _statusDisplay(order.status);

        return HoverableTableRow(
          index: i,
          isLast: i == orders.length - 1,
          child: Row(
            children: [
              TableDataCell(text: '${order.id}', flex: _Flex.id),
              TableDataCell(
                text: dateFormat.format(order.purchaseDate),
                flex: _Flex.date,
              ),
              Expanded(
                flex: _Flex.items,
                child: Text(
                  order.orderItems
                      .map((item) =>
                          '${item.supplementName} x${item.quantity}')
                      .join(', '),
                  style: AppTextStyles.bodySecondary,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              TableDataCell(
                text: '${order.totalAmount.toStringAsFixed(2)} KM',
                flex: _Flex.total,
              ),
              Expanded(
                flex: _Flex.status,
                child: _OrderStatusBadge(
                  label: statusDisplay.$1,
                  color: statusDisplay.$2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static (String, Color) _statusDisplay(OrderStatus status) {
    return switch (status) {
      OrderStatus.processing => ('U obradi', AppColors.warning),
      OrderStatus.delivered => ('Dostavljeno', AppColors.success),
      OrderStatus.cancelled => ('Otkazano', AppColors.danger),
    };
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
