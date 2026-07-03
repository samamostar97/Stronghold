import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Korpa')),
      body: cart.isEmpty
          ? const Center(child: Text('Korpa je prazna.'))
          : ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  title: Text(item.supplement.name),
                  subtitle: Text(
                    '${Formatters.money(item.supplement.price)} x ${item.quantity} = '
                    '${Formatters.money(item.subtotal)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => context
                            .read<CartProvider>()
                            .setQuantity(item.supplement.id, item.quantity - 1),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: item.quantity < item.supplement.stockQuantity
                            ? () => context
                                .read<CartProvider>()
                                .setQuantity(item.supplement.id, item.quantity + 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            context.read<CartProvider>().remove(item.supplement.id),
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
