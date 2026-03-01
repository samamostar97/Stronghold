import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';
import 'shared/surface_card.dart';

class ShopRecommendations extends StatefulWidget {
  final List<RecommendationResponse> items;

  const ShopRecommendations({super.key, required this.items});

  @override
  State<ShopRecommendations> createState() => _ShopRecommendationsState();
}

class _ShopRecommendationsState extends State<ShopRecommendations> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  static const _autoScrollInterval = Duration(seconds: 4);
  static const _userPauseDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.items.length <= 1) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onUserInteraction() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(_userPauseDuration, () {
      if (mounted) _startAutoScroll();
    });
  }

  void _navigateToDetail(RecommendationResponse rec) {
    context.push(
      '/shop/detail',
      extra: SupplementResponse(
        id: rec.id,
        name: rec.name,
        price: rec.price,
        description: rec.description,
        imageUrl: rec.imageUrl,
        supplementCategoryId: 0,
        supplementCategoryName: rec.categoryName,
        supplierId: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Text('Preporuceno za tebe', style: AppTextStyles.headingSm),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SizedBox(
                  height: 280,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null) {
                        _onUserInteraction();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.items.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) => _CarouselSlide(
                        rec: widget.items[i],
                        onTap: () => _navigateToDetail(widget.items[i]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.md,
                    top: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.items.length,
                      (i) => _Dot(isActive: i == _currentPage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Text('Svi suplementi', style: AppTextStyles.headingSm),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  final RecommendationResponse rec;
  final VoidCallback onTap;

  const _CarouselSlide({required this.rec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
            child: SizedBox(
              height: 172,
              width: double.infinity,
              child: rec.imageUrl != null
                  ? Image.network(
                      getFullImageUrl(rec.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.name,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rec.categoryName,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rec.recommendationReason,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textMuted, size: 32),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;

  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
