import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplement.dart';
import '../providers/cart_provider.dart';
import '../providers/shop_provider.dart';
import '../utils/formatters.dart';

class SupplementDetailsScreen extends StatelessWidget {
  final Supplement supplement;

  const SupplementDetailsScreen({super.key, required this.supplement});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(supplement.name)),
      body: ListView(
        children: [
          if (supplement.hasImage)
            Image.network(
              shop.imageUri(supplement.id).toString(),
              headers: shop.imageHeaders(),
              height: 260,
              fit: BoxFit.contain,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplement.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(supplement.categoryName),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(supplement.supplierName),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    Text(
                      supplement.reviewCount > 0
                          ? ' ${supplement.averageRating.toStringAsFixed(1)} (${supplement.reviewCount} recenzija)'
                          : ' Bez recenzija',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(supplement.description),
                const SizedBox(height: 16),
                Text(
                  supplement.stockQuantity > 0
                      ? 'Na stanju: ${supplement.stockQuantity} kom'
                      : 'Trenutno nema na stanju',
                  style: TextStyle(
                    color: supplement.stockQuantity > 0
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                Formatters.money(supplement.price),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Dodaj u korpu'),
                onPressed: supplement.stockQuantity > 0
                    ? () {
                        context.read<CartProvider>().add(supplement);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('"${supplement.name}" je dodan u korpu.'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
