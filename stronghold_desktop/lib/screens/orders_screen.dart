import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/order_provider.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/small_button.dart';
import '../widgets/status_pill.dart';
import '../widgets/success_animation.dart';

/// Refactored Orders Screen using Riverpod + generic patterns
/// Old: ~1,076 LOC | New: ~400 LOC (63% reduction)
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider.notifier).load();
    });
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
      final search = _searchController.text.trim();
      ref.read(orderListProvider.notifier).setSearch(search.isEmpty ? null : search);
    });
  }

  Future<void> _viewOrderDetails(OrderResponse order) async {
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

  Future<void> _markAsDelivered(OrderResponse order) async {
    if (order.status == OrderStatus.delivered) return;

    try {
      await ref.read(orderListProvider.notifier).markAsDelivered(order.id);
      if (mounted) {
        showSuccessAnimation(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'deliver-order'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);
    final notifier = ref.read(orderListProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 1200
            ? 40.0
            : constraints.maxWidth > 800
                ? 24.0
                : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
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
                  'Upravljanje narudzbama',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 28 : 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSearchBar(constraints),
                const SizedBox(height: 24),
                Expanded(child: _buildContent(state, notifier, constraints)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 600;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili email-u...',
          ),
          const SizedBox(height: 12),
          _buildSortDropdown(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili email-u...',
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedSort,
          hint: const Text(
            'Sortiraj',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          dropdownColor: AppColors.panel,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.sort, color: AppColors.muted, size: 20),
          items: const [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Zadano'),
            ),
            DropdownMenuItem<String?>(
              value: 'date',
              child: Text('Datum (najnovije)'),
            ),
            DropdownMenuItem<String?>(
              value: 'amount',
              child: Text('Iznos (opadajuce)'),
            ),
            DropdownMenuItem<String?>(
              value: 'status',
              child: Text('Status'),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedSort = value);
            ref.read(orderListProvider.notifier).setOrderBy(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    ListState<OrderResponse, OrderQueryFilter> state,
    OrderListNotifier notifier,
    BoxConstraints constraints,
  ) {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [1, 3, 2, 2, 2, 2]);
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greska pri ucitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Pokusaj ponovo', onTap: notifier.refresh),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _OrdersTable(
            orders: state.items,
            onViewDetails: _viewOrderDetails,
          ),
        ),
        const SizedBox(height: 16),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: notifier.goToPage,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ORDERS TABLE
// -----------------------------------------------------------------------------

abstract class _Flex {
  static const int orderId = 1;
  static const int user = 3;
  static const int total = 2;
  static const int date = 2;
  static const int status = 2;
  static const int actions = 2;
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({
    required this.orders,
    required this.onViewDetails,
  });

  final List<OrderResponse> orders;
  final ValueChanged<OrderResponse> onViewDetails;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Narudzba #', flex: _Flex.orderId),
            TableHeaderCell(text: 'Korisnik', flex: _Flex.user),
            TableHeaderCell(text: 'Ukupno', flex: _Flex.total),
            TableHeaderCell(text: 'Datum', flex: _Flex.date),
            TableHeaderCell(text: 'Status', flex: _Flex.status),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderRow(
        order: orders[i],
        index: i,
        isLast: i == orders.length - 1,
        onViewDetails: () => onViewDetails(orders[i]),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.index,
    required this.isLast,
    required this.onViewDetails,
  });

  final OrderResponse order;
  final int index;
  final bool isLast;
  final VoidCallback onViewDetails;

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      index: index,
      child: Row(
        children: [
          TableDataCell(text: '#${order.id}', flex: _Flex.orderId),
          Expanded(
            flex: _Flex.user,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.userFullName,
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.userEmail,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TableDataCell(text: _formatCurrency(order.totalAmount), flex: _Flex.total, muted: true),
          TableDataCell(text: _formatDate(order.purchaseDate), flex: _Flex.date),
          Expanded(
            flex: _Flex.status,
            child: Align(
              alignment: Alignment.centerLeft,
              child: order.status == OrderStatus.delivered
                  ? StatusPill.delivered()
                  : StatusPill.pending(),
            ),
          ),
          TableActionCell(
            flex: _Flex.actions,
            children: [
              SmallButton(
                text: 'Detalji',
                color: AppColors.editBlue,
                onTap: onViewDetails,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ORDER DETAILS DIALOG
// -----------------------------------------------------------------------------

class _OrderDetailsDialog extends StatelessWidget {
  const _OrderDetailsDialog({
    required this.order,
    required this.onMarkDelivered,
  });

  final OrderResponse order;
  final VoidCallback onMarkDelivered;

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  @override
  Widget build(BuildContext context) {
    final canMarkDelivered = order.status != OrderStatus.delivered;

    return Dialog(
      backgroundColor: AppColors.card,
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
                    'Narudzba #${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  order.status == OrderStatus.delivered
                      ? StatusPill.delivered()
                      : StatusPill.pending(),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: 'Korisnik', value: order.userFullName),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Email', value: order.userEmail),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Datum narudzbe', value: _formatDate(order.purchaseDate)),
                    if (order.stripePaymentId != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(label: 'ID placanja', value: order.stripePaymentId!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Order items header
              const Text(
                'Stavke narudzbe',
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
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Items header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border)),
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
                                border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
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
                                      style: const TextStyle(color: AppColors.muted, fontSize: 14),
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
                          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(flex: 7, child: Text('Ukupno za platiti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatCurrency(order.totalAmount),
                                style: const TextStyle(
                                  color: AppColors.accent,
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
                    child: const Text('Zatvori', style: TextStyle(color: AppColors.muted)),
                  ),
                  if (canMarkDelivered) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onMarkDelivered,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Oznaci kao dostavljeno'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
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
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
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
