import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/image_utils.dart';

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

  /// How long each slide stays visible before auto-advancing.
  static const _autoScrollInterval = Duration(seconds: 4);

  /// Pause duration after user swipes before auto-scroll resumes.
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
    // Pause auto-scroll, resume after delay
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
          child: Text(
            'Preporuceno za tebe',
            style: AppTextStyles.headingSm.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // PageView carousel
                SizedBox(
                  height: 290,
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
                // Dot indicators
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
          child: Text(
            'Svi suplementi',
            style: AppTextStyles.headingSm.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAROUSEL SLIDE
// ─────────────────────────────────────────────────────────────────────────────

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({required this.rec, required this.onTap});

  final RecommendationResponse rec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
            child: SizedBox(
              height: 180,
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
          // Info
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
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rec.categoryName,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  rec.recommendationReason,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.cyan,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
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
      color: AppColors.surface,
      child: const Center(
        child: Icon(LucideIcons.package, color: AppColors.textDark, size: 32),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOT INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cyan : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
