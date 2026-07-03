import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recommended_supplement.dart';
import '../models/supplement.dart';
import '../providers/cart_provider.dart';
import '../providers/shop_provider.dart';
import '../utils/formatters.dart';
import 'cart_screen.dart';
import 'supplement_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>();
      shop.load(page: 1, searchText: '', clearCategory: true);
      shop.loadRecommended();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prodavnica'),
        actions: [
          IconButton(
            tooltip: 'Korpa',
            icon: Badge(
              isLabelVisible: !cart.isEmpty,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pretraga proizvoda',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) =>
                  provider.load(page: 1, searchText: value.trim()),
            ),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.supplements.isEmpty
                    ? const Center(child: Text('Nema proizvoda za prikaz.'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.load();
                          await provider.loadRecommended();
                        },
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            if (provider.recommended.isNotEmpty) ...[
                              Text('Preporučeno za tebe',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 210,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.recommended.length,
                                  itemBuilder: (context, index) =>
                                      _recommendedCard(
                                          provider.recommended[index]),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('Svi proizvodi',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                            ],
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: provider.supplements.length,
                              itemBuilder: (context, index) =>
                                  _productCard(provider.supplements[index]),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedCard(RecommendedSupplement recommended) {
    final provider = context.read<ShopProvider>();
    final supplement = recommended.supplement;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SupplementDetailsScreen(supplement: supplement),
          ),
        ),
        child: SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: supplement.hasImage
                    ? Image.network(
                        provider.imageUri(supplement.id).toString(),
                        headers: provider.imageHeaders(),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        child:
                            const Center(child: Icon(Icons.image_not_supported)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // objasnjenje ZASTO se proizvod preporucuje
                    Text(
                      recommended.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(Supplement supplement) {
    final provider = context.read<ShopProvider>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SupplementDetailsScreen(supplement: supplement),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: supplement.hasImage
                  ? Image.network(
                      provider.imageUri(supplement.id).toString(),
                      headers: provider.imageHeaders(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: Icon(Icons.image_not_supported)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        supplement.reviewCount > 0
                            ? ' ${supplement.averageRating.toStringAsFixed(1)}'
                            : ' -',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const Spacer(),
                      Text(
                        Formatters.money(supplement.price),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
