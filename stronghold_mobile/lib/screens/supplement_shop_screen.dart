import 'package:flutter/material.dart';
import '../models/supplement_models.dart';
import '../services/supplement_service.dart';
import '../services/cart_service.dart';
import '../utils/image_utils.dart';
import 'supplement_detail_screen.dart';
import 'cart_screen.dart';
import '../widgets/feedback_dialog.dart';

class SupplementShopScreen extends StatefulWidget {
  const SupplementShopScreen({super.key});

  @override
  State<SupplementShopScreen> createState() => _SupplementShopScreenState();
}

class _SupplementShopScreenState extends State<SupplementShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CartService _cartService = CartService();

  List<Supplement> _supplements = [];
  List<SupplementCategory> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalCount = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _loadSupplements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showSuccessFeedback(String message) async {
    await showSuccessFeedback(context, message);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _supplements.length < _totalCount) {
      _loadMore();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await SupplementService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSupplements() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
    });

    try {
      final result = await SupplementService.getSupplements(
        pageNumber: 1,
        pageSize: _pageSize,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        setState(() {
          _supplements = result.items;
          _totalCount = result.totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final result = await SupplementService.getSupplements(
        pageNumber: _currentPage + 1,
        pageSize: _pageSize,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        setState(() {
          _currentPage++;
          _supplements.addAll(result.items);
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadSupplements();
  }

  void _onSearchSubmitted(String _) {
    _loadSupplements();
  }

  @override
  Widget build(BuildContext context) {
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
                          border: Border.all(
                            color: const Color(0xFFe63946).withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Prodavnica',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Cart icon with badge
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFe63946).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            if (_cartService.itemCount > 0)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFe63946),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '${_cartService.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
                    border: Border.all(
                      color: const Color(0xFFe63946).withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _onSearchSubmitted,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pretrazi suplemente...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _loadSupplements();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category chips
              if (_categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildCategoryChip(null, 'Sve'),
                      ..._categories.map(
                        (cat) => _buildCategoryChip(cat.id, cat.name),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFe63946),
                        ),
                      )
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadSupplements,
                                  child: const Text('Pokusaj ponovo'),
                                ),
                              ],
                            ),
                          )
                        : _supplements.isEmpty
                            ? Center(
                                child: Text(
                                  'Nema suplemenata',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _supplements.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _supplements.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFe63946),
                                        ),
                                      ),
                                    );
                                  }
                                  return _buildSupplementCard(_supplements[index]);
                                },
                              ),
              ),
            ],
          ),
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
            color: isSelected
                ? const Color(0xFFe63946)
                : const Color(0xFF0f0f1a),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFe63946)
                  : const Color(0xFFe63946).withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplementCard(Supplement supplement) {    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupplementDetailScreen(supplement: supplement),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFe63946).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: supplement.imageUrl != null && supplement.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        getFullImageUrl(supplement.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: Color(0xFFe63946),
                              size: 32,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: Color(0xFFe63946),
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supplement.categoryName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${supplement.price.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFe63946),
                    ),
                  ),
                ],
              ),
            ),
            // Add to cart button
            GestureDetector(
              onTap: () {
                _cartService.addItem(supplement);
                _showSuccessFeedback('${supplement.name} dodano u korpu');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFe63946).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_shopping_cart,
                  color: Color(0xFFe63946),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

