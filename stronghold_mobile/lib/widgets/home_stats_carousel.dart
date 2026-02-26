import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Stats carousel with 3 slides: XP Ring, Hot Streak, Leaderboard Rank.
/// Wrapped in a single GlassCard with < > navigation and dot indicators.
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;

    const slideColors = [AppColors.primary, AppColors.orange, AppColors.warning];
    final tint = slideColors[_currentPage];

    return GlassCard(
      padding: EdgeInsets.zero,
      backgroundColor: tint.withValues(alpha: 0.15),
      borderColor: tint.withValues(alpha: 0.3),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _XPRingSlide(progress: p),
                    _StreakSlide(progress: p),
                    _RankSlide(progress: p),
                  ],
                ),
                // Left arrow
                if (_currentPage > 0)
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        icon: Icons.chevron_left,
                        onTap: () => _goTo(_currentPage - 1),
                      ),
                    ),
                  ),
                // Right arrow
                if (_currentPage < 2)
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        icon: Icons.chevron_right,
                        onTap: () => _goTo(_currentPage + 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Dot indicators
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

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 1: XP RING
// ─────────────────────────────────────────────────────────────────────────────

class _XPRingSlide extends StatefulWidget {
  const _XPRingSlide({required this.progress});
  final UserProgressResponse progress;

  @override
  State<_XPRingSlide> createState() => _XPRingSlideState();
}

class _XPRingSlideState extends State<_XPRingSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final target = (widget.progress.progressPercentage / 100).clamp(0.0, 1.0);
    _fillAnimation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.huge,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Animated XP ring
          SizedBox(
            width: 110,
            height: 110,
            child: AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _XPRingPainter(
                    progress: _fillAnimation.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LV${p.level}',
                          style: AppTextStyles.headingMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.xpProgress} XP',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iskustvo',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${p.xpProgress} / ${p.xpForNextLevel} XP',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => context.push('/progress'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Pregled napretka',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 2: HOT STREAK
// ─────────────────────────────────────────────────────────────────────────────

class _StreakSlide extends StatelessWidget {
  const _StreakSlide({required this.progress});
  final UserProgressResponse progress;

  String _motivationMessage(int streak) {
    if (streak == 0) return 'Posjeti teretanu danas!';
    if (streak < 3) return 'Dobar pocetak, nastavi!';
    if (streak < 7) return 'Odlicno, ne odustaj!';
    if (streak < 14) return 'Nevjerovatan si!';
    if (streak < 30) return 'Masina! Niko te ne moze zaustaviti!';
    return 'Legenda teretane!';
  }

  @override
  Widget build(BuildContext context) {
    final streak = progress.currentStreakDays;
    final longest = progress.longestStreakDays;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.huge,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Flame icon area
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.orange.withValues(alpha: 0.3),
                  AppColors.orange.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: streak > 0 ? AppColors.orange : AppColors.textMuted,
                  size: 36,
                ),
                const SizedBox(height: 2),
                Text(
                  '$streak',
                  style: AppTextStyles.headingMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hot Streak',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  streak == 1 ? '1 dan zaredom' : '$streak dana zaredom',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _motivationMessage(streak),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (longest > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Najduzi: $longest dana',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
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

// ─────────────────────────────────────────────────────────────────────────────
// SLIDE 3: LEADERBOARD RANK
// ─────────────────────────────────────────────────────────────────────────────

class _RankSlide extends StatelessWidget {
  const _RankSlide({required this.progress});
  final UserProgressResponse progress;

  @override
  Widget build(BuildContext context) {
    final rank = progress.leaderboardRank;
    final total = progress.totalMembers;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.huge,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Trophy icon area
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.warning.withValues(alpha: 0.3),
                  AppColors.warning.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.warning,
                  size: 36,
                ),
                const SizedBox(height: 2),
                Text(
                  '#$rank',
                  style: AppTextStyles.headingMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rang',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'od $total clanova',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => context.push('/leaderboard'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Rang lista',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP RING PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _XPRingPainter extends CustomPainter {
  final double progress;

  _XPRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: const [
          AppColors.electric,
          AppColors.cyan,
          AppColors.electric,
        ],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_XPRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
      ),
    );
  }
}

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
