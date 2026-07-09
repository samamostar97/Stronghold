import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // svjeza korpa sa servera (moguce izmjene s drugog uredjaja)
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _run(() => context.read<CartProvider>().load()),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Korpa')),
      body: cart.isEmpty
          ? Center(
              child: cart.loading
                  ? const CircularProgressIndicator()
                  : const Text('Korpa je prazna.'),
            )
          : ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    '${Formatters.money(item.price)} x ${item.quantity} = '
                    '${Formatters.money(item.subtotal)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _run(() => context
                            .read<CartProvider>()
                            .setQuantity(item.supplementId, item.quantity - 1)),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: item.quantity < item.stockQuantity
                            ? () => _run(() => context
                                .read<CartProvider>()
                                .setQuantity(item.supplementId, item.quantity + 1))
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _run(() => context
                            .read<CartProvider>()
                            .remove(item.supplementId)),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ukupno'),
                        Text(
                          Formatters.money(cart.total),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Nastavi na plaćanje'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
