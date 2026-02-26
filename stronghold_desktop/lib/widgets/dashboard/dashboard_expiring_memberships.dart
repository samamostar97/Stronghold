import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class DashboardExpiringMemberships extends StatelessWidget {
  const DashboardExpiringMemberships({
    super.key,
    required this.items,
    required this.isLoading,
    this.error,
    required this.onRetry,
    this.expand = false,
  });

  final List<ActiveMemberResponse> items;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Clanarine koje isticu', style: AppTextStyles.headingSm),
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
        child: Text('Nema clanova kojima istice clanarina',
            style: AppTextStyles.bodyMd),
      );
    } else {
      content = ListView.builder(
        shrinkWrap: !expand,
        physics: expand
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) => _ExpiringRow(item: items[i]),
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

class _ExpiringRow extends StatelessWidget {
  const _ExpiringRow({required this.item});
  final ActiveMemberResponse item;

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        item.membershipEndDate.difference(DateTime.now()).inDays;
    final isToday = daysLeft <= 0;
    final badgeColor = isToday ? AppColors.danger : AppColors.orange;
    final badgeText = isToday ? 'Danas!' : 'za $daysLeft d';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(LucideIcons.userCircle, size: 16, color: badgeColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fullName,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(item.packageName, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.caption.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
