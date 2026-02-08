import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/date_format_utils.dart';
import '../models/order_models.dart';
import '../providers/order_provider.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final Set<int> _expandedOrders = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(orderListProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(orderListProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(orderListProvider.notifier).nextPage();
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} KM';
  }

  Color _getStatusBackgroundColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'processing':
        return const Color(0xFFFF9800).withValues(alpha: 0.2);
      case 'delivered':
        return const Color(0xFF4CAF50).withValues(alpha: 0.2);
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'processing':
        return const Color(0xFFFF9800);
      case 'delivered':
        return const Color(0xFF4CAF50);
      default:
        return Colors.white.withValues(alpha: 0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historija narudžbi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: _buildContent(orderState),
        ),
      ),
    );
  }

  Widget _buildContent(OrderListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }

    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(orderListProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Nemate narudžbi',
        subtitle: 'Vaša historija narudžbi će se prikazati ovdje',
      );
    }

    return _buildOrderList(state);
  }

  Widget _buildOrderList(OrderListState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(orderListProvider.notifier).refresh(),
      color: const Color(0xFFe63946),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFFe63946)),
              ),
            );
          }
          return _buildOrderCard(state.items[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isExpanded = _expandedOrders.contains(order.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedOrders.remove(order.id);
                } else {
                  _expandedOrders.add(order.id);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Narudžba ${formatDateDDMMYYYY(order.purchaseDate)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(order.statusName),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.statusNameBosnian,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusTextColor(order.statusName),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFe63946),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datum narudžbe',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDateDDMMYYYY(order.purchaseDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            () {
                              final totalQty = order.orderItems.fold<int>(0, (sum, item) => sum + item.quantity);
                              return '$totalQty artikl${totalQty == 1 ? '' : 'a'}';
                            }(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && order.orderItems.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFe63946).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: order.orderItems.map((item) => _buildOrderItemRow(item)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.supplementName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatCurrency(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(item.totalPrice),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
