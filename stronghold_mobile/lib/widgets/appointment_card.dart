import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/date_format_utils.dart';
import 'outline_button.dart';
import 'shared/surface_card.dart';

class AppointmentCard extends StatelessWidget {
  final UserAppointmentResponse appointment;
  final bool isCanceling;
  final VoidCallback onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isCanceling = false,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isTrainer = appointment.trainerName != null;
    final name = isTrainer
        ? appointment.trainerName
        : appointment.nutritionistName;
    final icon = isTrainer ? LucideIcons.dumbbell : LucideIcons.apple;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTrainer ? 'Trener' : 'Nutricionist',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name ?? 'Nepoznato',
                      style: AppTextStyles.headingSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _meta(
                LucideIcons.calendar,
                formatDateDDMMYYYY(appointment.appointmentDate),
              ),
              _meta(
                LucideIcons.clock,
                '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:00',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlineButton(
              label: 'Otkazi termin',
              color: const Color(0xFFEF4444),
              isLoading: isCanceling,
              onPressed: isCanceling ? null : onCancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 15),
        const SizedBox(width: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyMd),
      ],
    );
  }
}
