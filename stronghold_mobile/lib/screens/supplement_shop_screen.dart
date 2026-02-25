import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/cart_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/supplement_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/category_chip.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/search_bar_widget.dart';
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
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(supplementListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = ref.read(supplementListProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !s.isLoading &&
        s.hasNextPage) {
      ref.read(supplementListProvider.notifier).nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplementListProvider);
    final cartCount = ref.watch(cartProvider).itemCount;
    final catsAsync = ref.watch(supplementCategoriesProvider);
    final recsAsync = ref.watch(defaultRecommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _appBar(cartCount),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: SearchBarWidget(
              controller: _searchCtrl,
              hint: 'Pretrazi suplemente...',
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => ref
                  .read(supplementListProvider.notifier)
                  .setSearch(
                      _searchCtrl.text.isEmpty ? null : _searchCtrl.text),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                        ref
                            .read(supplementListProvider.notifier)
                            .setSearch(null);
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _categoryBar(catsAsync),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _body(state, recsAsync)),
        ]),
      ),
    );
  }

  Widget _appBar(int cartCount) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(children: [
        _iconBtn(LucideIcons.arrowLeft, () => context.go('/home')),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: Text('Prodavnica', style: AppTextStyles.headingMd)),
        GestureDetector(
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
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(LucideIcons.shoppingCart,
                    color: AppColors.textPrimary, size: 20),
                if (cartCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartCount',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w700,
                            fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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

  Widget _categoryBar(AsyncValue<List<SupplementCategoryResponse>> catsAsync) {
    return catsAsync.when(
      loading: () => const SizedBox(height: 38),
      error: (_, _) => const SizedBox(height: 38),
      data: (cats) {
        if (cats.isEmpty) return const SizedBox(height: 38);
        final labels = ['Sve', ...cats.map((c) => c.name)];
        final sel = _categoryId == null
            ? 0
            : cats.indexWhere((c) => c.id == _categoryId) + 1;
        return CategoryChips(
          labels: labels,
          selected: sel < 0 ? 0 : sel,
          onChanged: (i) {
            setState(() {
              _categoryId = i == 0 ? null : cats[i - 1].id;
            });
            ref
                .read(supplementListProvider.notifier)
                .setCategory(_categoryId);
          },
        );
      },
    );
  }

  Widget _body(SupplementListState state, AsyncValue recsAsync) {
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
        icon: LucideIcons.package,
        title: 'Nema suplemenata',
      );
    }
    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        recsAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (recs) =>
              SliverToBoxAdapter(child: ShopRecommendations(items: recs)),
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
                  onTap: () => context.push('/shop/detail', extra: s),
                  onAddToCart: () {
                    ref.read(cartProvider.notifier).addItem(s);
                    showSuccessFeedback(context, '${s.name} dodano u korpu');
                  },
                );
              },
              childCount: state.items.length +
                  (state.isLoading && state.items.isNotEmpty ? 1 : 0),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
  }
}
