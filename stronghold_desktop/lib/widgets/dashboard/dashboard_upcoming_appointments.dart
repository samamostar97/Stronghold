import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class DashboardUpcomingAppointments extends StatelessWidget {
  const DashboardUpcomingAppointments({
    super.key,
    required this.items,
    required this.isLoading,
    this.error,
    required this.onRetry,
    this.expand = false,
  });

  final List<AdminAppointmentResponse> items;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Nadolazeci termini', style: AppTextStyles.headingSm),
        const Spacer(),
        Text('${items.length}', style: AppTextStyles.caption),
      ],
    );

    Widget content;
    if (isLoading && items.isEmpty) {
      content = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    } else if (error != null && items.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Pokusaj ponovo')),
          ],
        ),
      );
    } else if (items.isEmpty) {
      content = Center(
        child: Text('Nema nadolazecih termina', style: AppTextStyles.bodyMd),
      );
    } else {
      content = ListView.builder(
        shrinkWrap: !expand,
        physics: expand
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) => _AppointmentRow(item: items[i]),
      );
    }

    return GlassCard(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.lg),
          if (expand) Expanded(child: content) else Flexible(child: content),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.item});
  final AdminAppointmentResponse item;

  @override
  Widget build(BuildContext context) {
    final dt = DateTimeUtils.toLocal(item.appointmentDate);
    final date =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. u ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final professional = item.trainerName ?? item.nutritionistName ?? '';
    final type = item.trainerName != null ? 'Trener' : 'Nutricionist';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.electric.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(LucideIcons.calendarCheck,
                size: 16, color: AppColors.electric),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.userName,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$type: $professional',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(date, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
