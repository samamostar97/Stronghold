import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Activity feed showing recent orders, registrations, and memberships.
class DashboardActivityFeed extends StatelessWidget {
  const DashboardActivityFeed({
    super.key,
    required this.items,
    this.expand = false,
  });

  final List<ActivityFeedItemDTO> items;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Aktivnosti', style: AppTextStyles.headingSm),
        const Spacer(),
        Text(
          '${items.length} posljednjih',
          style: AppTextStyles.caption,
        ),
      ],
    );

    final content = items.isEmpty
        ? Center(
            child: Text(
              'Nema nedavnih aktivnosti',
              style: AppTextStyles.bodyMd,
            ),
          )
        : ListView.builder(
            shrinkWrap: !expand,
            physics: expand
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: expand ? items.length : items.take(10).length,
            itemBuilder: (context, i) => _ActivityRow(item: items[i]),
          );

    if (!expand) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: AppSpacing.lg),
            Flexible(child: content),
          ],
        ),
      );
    }

    return GlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 100;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!compact) ...[
                header,
                const SizedBox(height: AppSpacing.lg),
              ],
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityFeedItemDTO item;

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(item.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(config.icon, size: 16, color: config.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (item.userName != null) ...[
                      Text(
                        item.userName!,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      _timeAgo(item.timestamp),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              config.label,
              style: AppTextStyles.caption.copyWith(
                color: config.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ({IconData icon, Color color, String label}) _typeConfig(String type) {
    return switch (type) {
      'order' => (
          icon: LucideIcons.shoppingCart,
          color: AppColors.success,
          label: 'Narudzba',
        ),
      'registration' => (
          icon: LucideIcons.userPlus,
          color: AppColors.primary,
          label: 'Registracija',
        ),
      'membership' => (
          icon: LucideIcons.creditCard,
          color: AppColors.warning,
          label: 'Clanarina',
        ),
      _ => (
          icon: LucideIcons.activity,
          color: AppColors.textMuted,
          label: type,
        ),
    };
  }

  static String _timeAgo(DateTime dt) {
    final localDt = DateTimeUtils.toLocal(dt);
    final diff = DateTime.now().difference(localDt);
    if (diff.inMinutes < 1) return 'upravo sada';
    if (diff.inMinutes < 60) return 'prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'prije ${diff.inHours}h';
    if (diff.inDays < 7) return 'prije ${diff.inDays}d';
    return '${localDt.day}.${localDt.month}.${localDt.year}';
  }
}
