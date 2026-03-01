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
import 'shared/surface_card.dart';

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
    Future.microtask(() => ref.read(myAppointmentsProvider.notifier).load());
  }

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
    final state = ref.watch(myAppointmentsProvider);
    final now = DateTime.now();
    final upcoming =
        state.items.where((a) => a.appointmentDate.isAfter(now)).toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    final nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 196,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _AppointmentSlide(appointment: nextAppointment),
                    _QuickLinkSlide(
                      title: 'Treneri',
                      subtitle: 'Zakazi trening sa trenerom',
                      icon: LucideIcons.dumbbell,
                      color: AppColors.success,
                      buttonLabel: 'Pogledaj trenere',
                      onTap: () => context.push('/trainers'),
                    ),
                    _QuickLinkSlide(
                      title: 'Nutricionisti',
                      subtitle: 'Plan ishrane i konsultacije',
                      icon: LucideIcons.apple,
                      color: AppColors.accent,
                      buttonLabel: 'Pogledaj nutricioniste',
                      onTap: () => context.push('/nutritionists'),
                    ),
                    _QuickLinkSlide(
                      title: 'Seminari',
                      subtitle: 'Radionice i edukacija',
                      icon: LucideIcons.graduationCap,
                      color: AppColors.orange,
                      buttonLabel: 'Svi seminari',
                      onTap: () => context.push('/seminars'),
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
                if (_currentPage < 3)
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

class _AppointmentSlide extends StatelessWidget {
  final UserAppointmentResponse? appointment;

  const _AppointmentSlide({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.28),
              ),
            ),
            child: a == null
                ? const Icon(
                    LucideIcons.calendarOff,
                    color: AppColors.textMuted,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(a.appointmentDate),
                        style: AppTextStyles.headingMd,
                      ),
                      Text(
                        DateFormat(
                          'MMM',
                          'bs',
                        ).format(a.appointmentDate).toUpperCase(),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sljedeci termin', style: AppTextStyles.headingSm),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  a != null
                      ? (a.trainerName ??
                            a.nutritionistName ??
                            'Nije definisano')
                      : 'Nemate zakazan termin',
                  style: AppTextStyles.bodySm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  a != null
                      ? '${DateFormat('dd.MM.yyyy').format(a.appointmentDate)} u ${DateFormat('HH:mm').format(a.appointmentDate)}'
                      : 'Rezervisi kroz tab Termine',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => context.go('/appointments'),
                  child: Text(
                    'Otvori termine',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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

class _QuickLinkSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonLabel;
  final VoidCallback onTap;

  const _QuickLinkSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.headingSm),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.bodySm),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: onTap,
                  child: Text(
                    buttonLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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
