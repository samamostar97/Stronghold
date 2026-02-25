import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/date_format_utils.dart';
import 'outline_button.dart';

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

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            const Icon(LucideIcons.calendar,
                color: AppColors.textMuted, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatDateDDMMYYYY(appointment.appointmentDate),
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(width: AppSpacing.lg),
            const Icon(LucideIcons.clock,
                color: AppColors.textMuted, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:00',
              style: AppTextStyles.bodyMd,
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlineButton(
              label: 'Otkazi termin',
              color: AppColors.error,
              isLoading: isCanceling,
              onPressed: isCanceling ? null : onCancel,
            ),
          ),
        ],
      ),
    );
  }
}
