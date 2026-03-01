import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'shared/surface_card.dart';

class HomeStatsCarousel extends StatefulWidget {
  const HomeStatsCarousel({super.key, required this.progress});

  final UserProgressResponse progress;

  @override
  State<HomeStatsCarousel> createState() => _HomeStatsCarouselState();
}

class _HomeStatsCarouselState extends State<HomeStatsCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _StatSlide(
                      title: 'Nivo i XP',
                      value: 'LV ${p.level}',
                      subtitle: '${p.xpProgress}/${p.xpForNextLevel} XP',
                      icon: Icons.bolt_rounded,
                      color: AppColors.primary,
                      actionLabel: 'Detalji napretka',
                      onTap: () => context.push('/progress'),
                    ),
                    _StatSlide(
                      title: 'Hot streak',
                      value: '${p.currentStreakDays} dana',
                      subtitle: 'Najduzi niz: ${p.longestStreakDays} dana',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.orange,
                    ),
                    _StatSlide(
                      title: 'Rang lista',
                      value: '#${p.leaderboardRank}',
                      subtitle: 'Od ${p.totalMembers} clanova',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.warning,
                      actionLabel: 'Otvori rang listu',
                      onTap: () => context.push('/leaderboard'),
                    ),
                  ],
                ),
                if (_currentPage > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: _ArrowButton(
                      icon: Icons.chevron_left,
                      onTap: () => _goTo(_currentPage - 1),
                    ),
                  ),
                if (_currentPage < 2)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: _ArrowButton(
                      icon: Icons.chevron_right,
                      onTap: () => _goTo(_currentPage + 1),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => _Dot(isActive: i == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSlide extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _StatSlide({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.bodySm),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.headingMd),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
                if (actionLabel != null && onTap != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: onTap,
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
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
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
