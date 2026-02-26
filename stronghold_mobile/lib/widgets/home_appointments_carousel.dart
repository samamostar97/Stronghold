import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/appointment_provider.dart';

/// Appointments carousel with 3 slides:
/// 1. Next upcoming appointment (or "no appointments" message)
/// 2. Trainers — quick link to book
/// 3. Nutritionists — quick link to book
class HomeAppointmentsCarousel extends ConsumerStatefulWidget {
  const HomeAppointmentsCarousel({super.key});

  @override
  ConsumerState<HomeAppointmentsCarousel> createState() =>
      _HomeAppointmentsCarouselState();
}

class _HomeAppointmentsCarouselState
    extends ConsumerState<HomeAppointmentsCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myAppointmentsProvider.notifier).load();
    });
  }

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
    final appointmentState = ref.watch(myAppointmentsProvider);
    final now = DateTime.now();
    final upcoming = appointmentState.items
        .where((a) => a.appointmentDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    final nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;

    const slideColors = [AppColors.secondary, AppColors.success, AppColors.accent, AppColors.orange];
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
                    _AppointmentSlide(appointment: nextAppointment),
                    _QuickLinkSlide(
                      icon: LucideIcons.dumbbell,
                      iconColor: AppColors.success,
                      label: 'Treneri',
                      description: 'Zakazi trening sa trenerom',
                      buttonLabel: 'Napravi termin',
                      onButtonTap: () => context.push('/trainers'),
                    ),
                    _QuickLinkSlide(
                      icon: LucideIcons.apple,
                      iconColor: AppColors.accent,
                      label: 'Nutricionisti',
                      description: 'Zakazi konsultaciju',
                      buttonLabel: 'Napravi termin',
                      onButtonTap: () => context.push('/nutritionists'),
                    ),
                    _QuickLinkSlide(
                      icon: LucideIcons.graduationCap,
                      iconColor: AppColors.orange,
                      label: 'Seminari',
                      description: 'Edukacija i radionice',
                      buttonLabel: 'Pregled seminara',
                      onButtonTap: () => context.push('/seminars'),
                    ),
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
                if (_currentPage < 3)
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
                4,
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
// SLIDE 1: NEXT APPOINTMENT
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentSlide extends StatelessWidget {
  const _AppointmentSlide({required this.appointment});
  final UserAppointmentResponse? appointment;

  @override
  Widget build(BuildContext context) {
    final a = appointment;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.huge,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Calendar icon area
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: a != null
                  ? [
                      Text(
                        DateFormat('dd').format(a.appointmentDate),
                        style: AppTextStyles.headingMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'bs').format(a.appointmentDate).toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                  : [
                      const Icon(
                        LucideIcons.calendarOff,
                        color: AppColors.textMuted,
                        size: 36,
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
                  'Sljedeci termin',
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (a != null) ...[
                  Text(
                    a.trainerName ?? a.nutritionistName ?? '',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(a.appointmentDate)} u ${DateFormat('HH:mm').format(a.appointmentDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Nemate termina',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => context.push('/appointments'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Moji termini',
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
// SLIDE 2 & 3: QUICK LINK (Trainers / Nutritionists)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickLinkSlide extends StatelessWidget {
  const _QuickLinkSlide({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.buttonLabel,
    required this.onButtonTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final String buttonLabel;
  final VoidCallback onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.huge,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Icon area
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  iconColor.withValues(alpha: 0.3),
                  iconColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: onButtonTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
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
        child:
            Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
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
        color:
            isActive ? AppColors.cyan : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
