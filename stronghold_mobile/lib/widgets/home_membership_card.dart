import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import 'glass_card.dart';
import 'ring_progress.dart';
import 'status_pill.dart';

class HomeMembershipCard extends ConsumerWidget {
  final bool hasActiveMembership;

  const HomeMembershipCard({
    super.key,
    required this.hasActiveMembership,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(membershipHistoryProvider);

    return history.when(
      loading: () => _placeholder(),
      error: (_, _) => _inactive(),
      data: (payments) {
        final active = payments.where((p) => p.isActive).toList();
        if (active.isEmpty) return _inactive();
        final membership = active.first;
        final daysLeft = membership.endDate.difference(DateTime.now()).inDays;
        final totalDays = membership.endDate
            .difference(membership.startDate)
            .inDays;
        final pct = totalDays > 0
            ? ((totalDays - daysLeft) / totalDays * 100).clamp(0.0, 100.0)
            : 100.0;
        final expiringSoon = daysLeft <= 7;

        return GlassCard(
          child: Row(children: [
            RingProgress(
              percentage: pct,
              color: expiringSoon ? AppColors.warning : AppColors.primary,
              size: 56,
              strokeWidth: 5,
              centerChild: Text(
                '$daysLeft',
                style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        membership.packageName,
                        style: AppTextStyles.headingSm,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusPill(
                      label: expiringSoon ? 'Istice' : 'Aktivna',
                      color: expiringSoon
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$daysLeft dana preostalo',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _inactive() {
    return GlassCard(
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.errorDim,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.shieldOff,
              size: 20, color: AppColors.error),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Neaktivna clanarina', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Kontaktirajte recepciju za obnovu',
                style: AppTextStyles.bodySm,
              ),
            ],
          ),
        ),
        const StatusPill(label: 'Neaktivna', color: AppColors.error),
      ]),
    );
  }

  Widget _placeholder() {
    return GlassCard(
      child: SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
