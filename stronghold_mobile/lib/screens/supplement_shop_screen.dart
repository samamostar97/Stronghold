import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplement_models.dart';
import '../models/recommendation.dart';
import '../providers/supplement_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/recommendation_provider.dart';
import '../utils/image_utils.dart';
import 'supplement_detail_screen.dart';
import 'cart_screen.dart';
import '../widgets/feedback_dialog.dart';

class SupplementShopScreen extends ConsumerStatefulWidget {
  const SupplementShopScreen({super.key});

  @override
  ConsumerState<SupplementShopScreen> createState() => _SupplementShopScreenState();
}

class _SupplementShopScreenState extends ConsumerState<SupplementShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    Future.microtask(() {
      ref.read(supplementListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(supplementListProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(supplementListProvider.notifier).nextPage();
    }
  }

  Supplement _recommendationToSupplement(Recommendation rec) {
    return Supplement(
      id: rec.id,
      name: rec.name,
      price: rec.price,
      description: rec.description,
      imageUrl: rec.imageUrl,
      categoryId: 0,
      categoryName: rec.categoryName,
    );
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    ref.read(supplementListProvider.notifier).setCategory(categoryId);
  }

  void _onSearchSubmitted(String _) {
    ref.read(supplementListProvider.notifier).setSearch(_searchController.text.isEmpty ? null : _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final supplementState = ref.watch(supplementListProvider);
    final cartState = ref.watch(cartProvider);
    final categoriesAsync = ref.watch(supplementCategoriesProvider);
    final recommendationsAsync = ref.watch(defaultRecommendationsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text('Prodavnica', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2)),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                            if (cartState.itemCount > 0)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFFe63946), shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text('${cartState.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f0f1a),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _onSearchSubmitted,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pretrazi suplemente...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.4)),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(supplementListProvider.notifier).setSearch(null);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category chips
              categoriesAsync.when(
                loading: () => const SizedBox(height: 40),
                error: (_, __) => const SizedBox(height: 40),
                data: (categories) => categories.isNotEmpty
                    ? SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildCategoryChip(null, 'Sve'),
                            ...categories.map((cat) => _buildCategoryChip(cat.id, cat.name)),
                          ],
                        ),
                      )
                    : const SizedBox(height: 40),
              ),

              const SizedBox(height: 12),

              // Content
              Expanded(
                child: supplementState.isLoading && supplementState.items.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFe63946)))
                    : supplementState.error != null && supplementState.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.white.withValues(alpha: 0.5), size: 48),
                                const SizedBox(height: 16),
                                Text(supplementState.error!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16), textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: () => ref.read(supplementListProvider.notifier).load(), child: const Text('Pokusaj ponovo')),
                              ],
                            ),
                          )
                        : supplementState.items.isEmpty
                            ? Center(child: Text('Nema suplemenata', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)))
                            : CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  // Recommendations section
                                  recommendationsAsync.when(
                                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                                    data: (recommendations) => recommendations.isNotEmpty
                                        ? SliverToBoxAdapter(child: _buildRecommendationsSection(recommendations))
                                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                                  ),
                                  // Supplements list
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          if (index == supplementState.items.length) {
                                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Color(0xFFe63946))));
                                          }
                                          return _buildSupplementCard(supplementState.items[index]);
                                        },
                                        childCount: supplementState.items.length + (supplementState.isLoading && supplementState.items.isNotEmpty ? 1 : 0),
                                      ),
                                    ),
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

  Widget _buildRecommendationsSection(List<Recommendation> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFe63946).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.recommend, color: Color(0xFFe63946), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Preporuceno za tebe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recommendations.length,
            itemBuilder: (context, index) => _buildRecommendationCard(recommendations[index]),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Svi suplementi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupplementDetailScreen(supplement: _recommendationToSupplement(recommendation)))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(color: Color(0xFF1a1a2e), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: recommendation.imageUrl != null && recommendation.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      child: Image.network(getFullImageUrl(recommendation.imageUrl), width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.fitness_center, color: Color(0xFFe63946), size: 32))),
                    )
                  : const Center(child: Icon(Icons.fitness_center, color: Color(0xFFe63946), size: 32)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recommendation.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFffc107), size: 14),
                      const SizedBox(width: 4),
                      Text(recommendation.averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      Text(' (${recommendation.reviewCount})', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(recommendation.categoryName, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('${recommendation.price.toStringAsFixed(2)} KM', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFe63946))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(int? categoryId, String name) {
    final isSelected = _selectedCategoryId == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _onCategorySelected(categoryId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFe63946) : const Color(0xFF0f0f1a),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFFe63946) : const Color(0xFFe63946).withValues(alpha: 0.2)),
          ),
          child: Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _buildSupplementCard(Supplement supplement) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupplementDetailScreen(supplement: supplement))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(12)),
              child: supplement.imageUrl != null && supplement.imageUrl!.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(getFullImageUrl(supplement.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.fitness_center, color: Color(0xFFe63946), size: 32))))
                  : const Center(child: Icon(Icons.fitness_center, color: Color(0xFFe63946), size: 32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplement.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(supplement.categoryName, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 8),
                  Text('${supplement.price.toStringAsFixed(2)} KM', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFe63946))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(cartProvider.notifier).addItem(supplement);
                showSuccessFeedback(context, '${supplement.name} dodano u korpu');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFe63946).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_shopping_cart, color: Color(0xFFe63946), size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
