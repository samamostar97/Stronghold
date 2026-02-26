import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import 'package:stronghold_core/stronghold_core.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isSearching) return;
    final s = ref.read(supplementListProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !s.isLoading &&
        s.hasNextPage) {
      ref.read(supplementListProvider.notifier).nextPage();
    }
  }

  void _startSearch(String query) {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }
    setState(() => _isSearching = true);
    ref.read(supplementListProvider.notifier).setSearch(query);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _isSearching = false);
    ref.read(supplementListProvider.notifier).setSearch(null);
  }

  void _onSupplementTap(SupplementResponse s) {
    context.push('/shop/detail', extra: s);
  }

  void _onAddToCart(SupplementResponse s) {
    ref.read(cartProvider.notifier).addItem(s);
    showSuccessFeedback(context, '${s.name} dodano u korpu');
  }

  /// "Pogledaj sve" for a category — triggers search mode filtered by category
  void _onViewAllCategory(SupplementCategoryResponse cat) {
    setState(() => _isSearching = true);
    ref.read(supplementListProvider.notifier).setCategory(cat.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(children: [
          _appBar()
              .animate()
              .fadeIn(duration: Motion.smooth, curve: Motion.curve),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: SearchBarWidget(
              controller: _searchCtrl,
              hint: 'Pretrazi suplemente...',
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _startSearch(_searchCtrl.text.trim()),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 18),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _isSearching ? _searchResults() : _browseBody(),
          ),
        ]),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BROWSE MODE — Recommendations carousel + category sections
  // ───────────────────────────────────────────────────────────────────────────

  Widget _browseBody() {
    final recsAsync = ref.watch(defaultRecommendationsProvider);
    final catsAsync = ref.watch(supplementCategoriesProvider);

    return catsAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => AppErrorState(
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
          itemCount: categories.length + 1, // +1 for recommendations
          itemBuilder: (context, i) {
            // First item: recommendations carousel
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
            // Category sections
            final cat = categories[i - 1];
            return ShopCategorySection(
              category: cat,
              onSupplementTap: _onSupplementTap,
              onAddToCart: _onAddToCart,
              onViewAll: () => _onViewAllCategory(cat),
            )
                .animate(delay: (200 + i * 100).ms)
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

  // ───────────────────────────────────────────────────────────────────────────
  // SEARCH MODE — Flat paginated grid of results
  // ───────────────────────────────────────────────────────────────────────────

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
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
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
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  );
                }
                final s = state.items[i];
                return SupplementCard(
                  supplement: s,
                  onTap: () => _onSupplementTap(s),
                  onAddToCart: () => _onAddToCart(s),
                );
              },
              childCount: state.items.length +
                  (state.isLoading && state.items.isNotEmpty ? 1 : 0),
            ),
          ),
        ),
        const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // APP BAR
  // ───────────────────────────────────────────────────────────────────────────

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(children: [
        _iconBtn(LucideIcons.arrowLeft, () {
          if (_isSearching) {
            _clearSearch();
          } else {
            context.go('/home');
          }
        }),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            _isSearching ? 'Rezultati pretrage' : 'Prodavnica',
            style: AppTextStyles.headingMd.copyWith(color: Colors.white),
          ),
        ),
      ]),
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
