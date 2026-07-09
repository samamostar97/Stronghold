import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../providers/reviews_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load(page: 1);
      context.read<ReviewsProvider>().loadMine();
    });
  }

  Future<void> _openReviewDialog(OrderItem item) async {
    int rating = 5;
    final commentController = TextEditingController();
    String? serverError;
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text('Ocijenite: ${item.supplementName}')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var star = 1; star <= 5; star++)
                    IconButton(
                      icon: Icon(
                        star <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setDialogState(() => rating = star),
                    ),
                ],
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Komentar (opcionalno)',
                ),
                maxLines: 3,
              ),
              if (serverError != null) ...[
                const SizedBox(height: 12),
                Text(
                  serverError!,
                  style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() {
                        submitting = true;
                        serverError = null;
                      });
                      try {
                        await context.read<ReviewsProvider>().create(
                              supplementId: item.supplementId,
                              rating: rating,
                              comment: commentController.text.trim().isEmpty
                                  ? null
                                  : commentController.text.trim(),
                            );
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Recenzija za "${item.supplementName}" je sačuvana.')),
                          );
                        }
                      } on ApiException catch (e) {
                        if (dialogContext.mounted) {
                          setDialogState(() {
                            serverError = e.message;
                            submitting = false;
                          });
                        }
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sačuvaj ocjenu'),
            ),
          ],
        ),
      ),
    );
  }

  StatusTone _statusTone(String status) => switch (status) {
        'Delivered' => StatusTone.success,
        'Cancelled' => StatusTone.danger,
        _ => StatusTone.warning,
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
    final reviews = context.watch<ReviewsProvider>();

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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            StatusChip(
              label: Formatters.orderStatus(order.status),
              tone: _statusTone(order.status),
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
              trailing: order.status != 'Delivered'
                  ? Text(Formatters.money(item.unitPrice * item.quantity))
                  // recenzija samo za dostavljeno; jedna po proizvodu
                  : reviews.hasReviewed(item.supplementId)
                      ? const Chip(
                          avatar: Icon(Icons.star, size: 16, color: Colors.amber),
                          label: Text('Ocijenjeno'),
                          visualDensity: VisualDensity.compact,
                        )
                      : TextButton.icon(
                          icon: const Icon(Icons.star_border, size: 18),
                          label: const Text('Ocijeni'),
                          onPressed: () => _openReviewDialog(item),
                        ),
            ),
        ],
      ),
    );
  }
}
