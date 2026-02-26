import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class DashboardUpcomingSeminars extends StatelessWidget {
  const DashboardUpcomingSeminars({
    super.key,
    required this.items,
    required this.isLoading,
    this.error,
    required this.onRetry,
    this.expand = false,
  });

  final List<SeminarResponse> items;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Nadolazeci seminari', style: AppTextStyles.headingSm),
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
        child:
            Text('Nema nadolazecih seminara', style: AppTextStyles.bodyMd),
      );
    } else {
      content = ListView.builder(
        shrinkWrap: !expand,
        physics: expand
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) => _SeminarRow(item: items[i]),
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

class _SeminarRow extends StatelessWidget {
  const _SeminarRow({required this.item});
  final SeminarResponse item;

  @override
  Widget build(BuildContext context) {
    final dt = DateTimeUtils.toLocal(item.eventDate);
    final date =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(LucideIcons.graduationCap,
                size: 16, color: AppColors.purple),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.topic,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(item.speakerName, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                '${item.currentAttendees}/${item.maxCapacity}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
