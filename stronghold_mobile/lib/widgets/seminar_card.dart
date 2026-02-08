import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../models/seminar.dart';
import '../utils/date_format_utils.dart';
import 'glass_card.dart';
import 'gradient_button.dart';
import 'outline_button.dart';
import 'status_pill.dart';

class SeminarCard extends StatelessWidget {
  final Seminar seminar;
  final bool isAttendLoading;
  final bool isCancelLoading;
  final VoidCallback onAttend;
  final VoidCallback onCancel;

  const SeminarCard({
    super.key,
    required this.seminar,
    required this.isAttendLoading,
    required this.isCancelLoading,
    required this.onAttend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(seminar.topic, style: AppTextStyles.headingSm),
              ),
              if (seminar.isAttending) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusPill(label: 'Prijavljen', color: AppColors.success),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _infoRow(LucideIcons.user, 'Predavac:', seminar.speakerName),
          const SizedBox(height: AppSpacing.sm),
          _infoRow(LucideIcons.calendar, 'Datum:',
              formatDateDDMMYYYY(seminar.eventDate)),
          const SizedBox(height: AppSpacing.lg),
          if (seminar.isAttending)
            OutlineButton(
              label: 'Odjavi se',
              isLoading: isCancelLoading,
              onPressed: onCancel,
              color: AppColors.error,
              fullWidth: true,
            )
          else
            GradientButton(
              label: 'Prijavi se',
              icon: LucideIcons.calendarPlus,
              isLoading: isAttendLoading,
              onPressed: onAttend,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: AppSpacing.sm),
      Text(label, style: AppTextStyles.bodySm),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(value,
            style: AppTextStyles.bodyMd, overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}
