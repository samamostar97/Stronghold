import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/cart_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/supplement_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shop_category_section.dart';
import '../widgets/shop_recommendations.dart';
import '../widgets/supplement_card.dart';

class SupplementShopScreen extends ConsumerStatefulWidget {
  const SupplementShopScreen({super.key});

  @override
  ConsumerState<SupplementShopScreen> createState() =>
      _SupplementShopScreenState();
}

class _SupplementShopScreenState extends ConsumerState<SupplementShopScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isSearching = false;
  _ShopSortOption _selectedSort = _ShopSortOption.featured;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(supplementListProvider);
      if (!mounted) return;
      setState(() {
        _isSearching = _hasCatalogFilters(state);
        _selectedSort = _ShopSortOptionX.fromOrderBy(state.orderBy);
      });
      if ((state.search ?? '').isNotEmpty) {
        _searchCtrl.text = state.search!;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _hasCatalogFilters(SupplementListState state) {
    return (state.search?.isNotEmpty ?? false) ||
        state.categoryId != null ||
        ((state.orderBy ?? '').isNotEmpty);
  }

  void _onScroll() {
    if (!_isSearching) return;
    final state = ref.read(supplementListProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasNextPage) {
      ref.read(supplementListProvider.notifier).nextPage();
    }
  }

  Future<void> _startSearch(String query) async {
    if (query.isEmpty) {
      await _clearSearch();
      return;
    }
    setState(() => _isSearching = true);
    await ref.read(supplementListProvider.notifier).setSearch(query);
  }

  Future<void> _clearSearch() async {
    _searchCtrl.clear();
    await ref.read(supplementListProvider.notifier).setSearch(null);
    final state = ref.read(supplementListProvider);
    if (!mounted) return;
    setState(() {
      _isSearching = _hasCatalogFilters(state);
    });
  }

  Future<void> _selectCategory(int? categoryId) async {
    await ref.read(supplementListProvider.notifier).setCategory(categoryId);
    final state = ref.read(supplementListProvider);
    if (!mounted) return;
    setState(() {
      _isSearching = _hasCatalogFilters(state);
    });
  }

  Future<void> _applySort(_ShopSortOption option) async {
    setState(() => _selectedSort = option);
    await ref.read(supplementListProvider.notifier).setOrderBy(option.orderBy);
    final state = ref.read(supplementListProvider);
    if (!mounted) return;
    setState(() {
      _isSearching = _hasCatalogFilters(state);
    });
  }

  void _onSupplementTap(SupplementResponse supplement) {
    context.push('/shop/detail', extra: supplement);
  }

  void _onAddToCart(SupplementResponse supplement) {
    ref.read(cartProvider.notifier).addItem(supplement);
    showSuccessFeedback(context, '${supplement.name} dodano u korpu');
  }

  Future<void> _onViewAllCategory(SupplementCategoryResponse category) async {
    await _selectCategory(category.id);
  }

  Future<void> _clearFilters() async {
    _searchCtrl.clear();
    await ref.read(supplementListProvider.notifier).resetFilters();
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _selectedSort = _ShopSortOption.featured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(
              cartCount,
            ).animate().fadeIn(duration: Motion.smooth, curve: Motion.curve),
            Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: SearchBarWidget(
                    controller: _searchCtrl,
                    hint: 'Pretrazi suplemente...',
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _startSearch(_searchCtrl.text.trim()),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: Motion.smooth, curve: Motion.curve),
            const SizedBox(height: AppSpacing.md),
            _catalogControls(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _isSearching ? _searchResults() : _browseBody()),
          ],
        ),
      ),
    );
  }

  Widget _catalogControls() {
    final categoriesAsync = ref.watch(supplementCategoriesProvider);
    final listState = ref.watch(supplementListProvider);
    final hasFilters = _hasCatalogFilters(listState);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: PopupMenuButton<_ShopSortOption>(
                      initialValue: _selectedSort,
                      onSelected: _applySort,
                      itemBuilder: (context) => _ShopSortOption.values
                          .map(
                            (option) => PopupMenuItem<_ShopSortOption>(
                              value: option,
                              child: Text(
                                option.label,
                                style: AppTextStyles.bodySm,
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.arrowUpDown,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _selectedSort.label,
                                style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronDown,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasFilters) ...[
                    const SizedBox(width: AppSpacing.sm),
                    InkWell(
                      onTap: _clearFilters,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            'Reset',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            categoriesAsync.when(
              loading: () => const SizedBox(
                height: 34,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) {
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    children: [
                      _categoryChip(
                        label: 'Sve',
                        active: listState.categoryId == null,
                        onTap: () => _selectCategory(null),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: _categoryChip(
                            label: category.name,
                            active: listState.categoryId == category.id,
                            onTap: () => _selectCategory(category.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _browseBody() {
    final recsAsync = ref.watch(defaultRecommendationsProvider);
    final categoriesAsync = ref.watch(supplementCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (_, __) => AppErrorState(
        message: 'Greska pri ucitavanju kategorija',
        onRetry: () => ref.invalidate(supplementCategoriesProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.package,
            title: 'Nema suplemenata',
          );
        }
        return ListView.builder(
          controller: _scrollCtrl,
          itemCount: categories.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return recsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (recs) => ShopRecommendations(items: recs)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                    .slideY(
                      begin: 0.04,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve,
                    ),
              );
            }
            final category = categories[i - 1];
            return ShopCategorySection(
                  category: category,
                  onSupplementTap: _onSupplementTap,
                  onAddToCart: _onAddToCart,
                  onViewAll: () => _onViewAllCategory(category),
                )
                .animate(delay: (200 + i * 80).ms)
                .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve,
                );
          },
        );
      },
    );
  }

  Widget _searchResults() {
    final state = ref.watch(supplementListProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(supplementListProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.search,
        title: 'Nema rezultata',
      );
    }

    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '${state.totalCount} rezultata',
                style: AppTextStyles.bodySm,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == state.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                final supplement = state.items[i];
                return SupplementCard(
                  supplement: supplement,
                  onTap: () => _onSupplementTap(supplement),
                  onAddToCart: supplement.isInStock
                      ? () => _onAddToCart(supplement)
                      : null,
                );
              },
              childCount:
                  state.items.length +
                  (state.isLoading && state.items.isNotEmpty ? 1 : 0),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
  }

  Widget _appBar(int cartCount) {
    final canGoBack = Navigator.of(context).canPop();
    final title = _isSearching ? 'Katalog' : 'Prodavnica';
    final subtitle = _isSearching
        ? 'Rezultati i filteri'
        : 'Suplementi i oprema';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          if (_isSearching || canGoBack)
            _iconBtn(LucideIcons.arrowLeft, () {
              if (_isSearching) {
                if (_searchCtrl.text.isNotEmpty) {
                  _clearSearch();
                } else {
                  _clearFilters();
                }
              } else if (canGoBack) {
                context.pop();
              }
            }),
          if (!_isSearching && !canGoBack)
            Container(
              width: AppSpacing.touchTarget,
              height: AppSpacing.touchTarget,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                LucideIcons.shoppingBag,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.headingMd),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/cart'),
            child: Container(
              width: AppSpacing.touchTarget,
              height: AppSpacing.touchTarget,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      LucideIcons.shoppingCart,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 9 ? '9+' : '$cartCount',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
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
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.touchTarget,
        height: AppSpacing.touchTarget,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

enum _ShopSortOption { featured, newest, priceAsc, priceDesc, nameAsc }

extension _ShopSortOptionX on _ShopSortOption {
  String get label {
    return switch (this) {
      _ShopSortOption.featured => 'Istaknuto',
      _ShopSortOption.newest => 'Najnovije',
      _ShopSortOption.priceAsc => 'Cijena: niza',
      _ShopSortOption.priceDesc => 'Cijena: visa',
      _ShopSortOption.nameAsc => 'Naziv A-Z',
    };
  }

  String? get orderBy {
    return switch (this) {
      _ShopSortOption.featured => null,
      _ShopSortOption.newest => 'createdatdesc',
      _ShopSortOption.priceAsc => 'price',
      _ShopSortOption.priceDesc => 'pricedesc',
      _ShopSortOption.nameAsc => 'name',
    };
  }

  static _ShopSortOption fromOrderBy(String? orderBy) {
    return switch ((orderBy ?? '').toLowerCase()) {
      'createdatdesc' => _ShopSortOption.newest,
      'price' => _ShopSortOption.priceAsc,
      'pricedesc' => _ShopSortOption.priceDesc,
      'name' => _ShopSortOption.nameAsc,
      _ => _ShopSortOption.featured,
    };
  }
}
