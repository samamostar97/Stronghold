import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../utils/formatters.dart';

/// Historija narudzbi - master lista, detalji stavki se sire po narudzbi.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrdersProvider>().load(page: 1),
    );
  }

  Color _statusColor(BuildContext context, String status) => switch (status) {
        'Delivered' => Colors.green.shade700,
        'Cancelled' => Theme.of(context).colorScheme.error,
        _ => Colors.orange.shade800,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Moje narudžbe')),
      body: provider.loading && provider.orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.orders.isEmpty
              ? const Center(child: Text('Nemate narudžbi.'))
              : RefreshIndicator(
                  onRefresh: () => provider.load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) =>
                        _orderCard(provider.orders[index]),
                  ),
                ),
    );
  }

  Widget _orderCard(Order order) {
    return Card(
      child: ExpansionTile(
        title: Text('Narudžba #${order.id}'),
        subtitle: Text(
          '${Formatters.dateTime(order.createdAt)} - ${order.itemCount} '
          '${order.itemCount == 1 ? 'artikal' : 'artikala'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.money(order.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              Formatters.orderStatus(order.status),
              style: TextStyle(color: _statusColor(context, order.status)),
            ),
          ],
        ),
        children: [
          for (final item in order.items)
            ListTile(
              dense: true,
              title: Text(item.supplementName),
              subtitle: Text(
                  '${Formatters.money(item.unitPrice)} x ${item.quantity}'),
              trailing: Text(Formatters.money(item.unitPrice * item.quantity)),
            ),
        ],
      ),
    );
  }
}
