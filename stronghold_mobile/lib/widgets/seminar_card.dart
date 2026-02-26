import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../utils/date_format_utils.dart';
import 'outline_button.dart';

class SeminarCard extends StatelessWidget {
  final UserSeminarResponse seminar;
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
                child: Text(seminar.topic, style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
              ),
              if (seminar.isCancelled) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusPill(label: 'Otkazan', color: AppColors.error),
              ] else if (seminar.isAttending) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF158C6E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF158C6E).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: const Color(0xFF158C6E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Prijavljen', style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.33,
                        color: Color(0xFF22D3A7),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _infoRow(LucideIcons.user, 'Predavac:', seminar.speakerName),
          const SizedBox(height: AppSpacing.sm),
          _infoRow(
            LucideIcons.calendar,
            'Datum:',
            formatDateDDMMYYYY(seminar.eventDate),
          ),
          const SizedBox(height: AppSpacing.sm),
          _capacityRow(),
          const SizedBox(height: AppSpacing.lg),
          if (seminar.isCancelled)
            StatusPill(label: 'Nedostupno', color: AppColors.textMuted)
          else if (seminar.isAttending)
            OutlineButton(
              label: 'Odjavi se',
              isLoading: isCancelLoading,
              onPressed: onCancel,
              color: AppColors.error,
              fullWidth: true,
            )
          else if (seminar.isFull)
            StatusPill(label: 'Popunjeno', color: AppColors.error)
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

  Widget _capacityRow() {
    final ratio = seminar.maxCapacity > 0
        ? (seminar.currentAttendees / seminar.maxCapacity).clamp(0.0, 1.0)
        : 0.0;
    final color = seminar.isFull
        ? AppColors.error
        : ratio > 0.8
        ? AppColors.warning
        : AppColors.success;

    return Row(
      children: [
        Icon(LucideIcons.users, size: 16, color: Colors.white),
        const SizedBox(width: AppSpacing.sm),
        Text('Mjesta:', style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${seminar.currentAttendees}/${seminar.maxCapacity}',
          style: AppTextStyles.bodyMd.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
