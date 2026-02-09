import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/appointment_models.dart';
import '../providers/appointment_provider.dart';
import '../screens/appointment_screen.dart';
import 'glass_card.dart';

class HomeNextAppointment extends ConsumerStatefulWidget {
  const HomeNextAppointment({super.key});

  @override
  ConsumerState<HomeNextAppointment> createState() =>
      _HomeNextAppointmentState();
}

class _HomeNextAppointmentState extends ConsumerState<HomeNextAppointment> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(myAppointmentsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myAppointmentsProvider);

    if (state.isLoading && state.items.isEmpty) {
      return _loadingCard();
    }

    final now = DateTime.now();
    final upcoming = state.items
        .where((a) => a.appointmentDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    if (upcoming.isEmpty) {
      return _emptyCard(context);
    }

    return _appointmentCard(context, upcoming.first);
  }

  Widget _loadingCard() {
    return const GlassCard(
      child: SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context) {
    return GlassCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentScreen()),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(LucideIcons.calendarPlus,
                size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nemate zakazanih termina',
                    style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text('Zakazite svoj prvi termin',
                    style: AppTextStyles.bodySm),
              ],
            ),
          ),
          const Icon(LucideIcons.arrowRight,
              size: 16, color: AppColors.secondary),
        ],
      ),
    );
  }

  Widget _appointmentCard(BuildContext context, Appointment appointment) {
    final dateFormat = DateFormat('dd. MMM yyyy', 'bs');
    final timeFormat = DateFormat('HH:mm');
    final professional =
        appointment.trainerName ?? appointment.nutritionistName ?? '';

    return GlassCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentScreen()),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(LucideIcons.calendar,
                size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(professional, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  '${dateFormat.format(appointment.appointmentDate)} u ${timeFormat.format(appointment.appointmentDate)}',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          Text('Vidi sve',
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.secondary)),
        ],
      ),
    );
  }
}
