import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class DashboardAdminActivityFeed extends StatelessWidget {
  const DashboardAdminActivityFeed({
    super.key,
    required this.items,
    required this.isLoading,
    required this.undoInProgressIds,
    required this.onUndo,
    required this.onRetry,
    this.error,
    this.expand = false,
  });

  final List<AdminActivityResponse> items;
  final bool isLoading;
  final Set<int> undoInProgressIds;
  final Future<void> Function(int id) onUndo;
  final VoidCallback onRetry;
  final String? error;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Text('Nedavne aktivnosti', style: AppTextStyles.headingSm),
        const Spacer(),
        Text('${items.length} stavki', style: AppTextStyles.caption),
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
            const SizedBox(height: AppSpacing.sm),
            Text('Pokusajte ponovo.', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    } else if (items.isEmpty) {
      content = Center(
        child: Text('Nema aktivnosti', style: AppTextStyles.bodyMd),
      );
    } else {
      content = ListView.builder(
        shrinkWrap: !expand,
        physics: expand
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: expand ? items.length : items.take(8).length,
        itemBuilder: (context, i) => _ActivityRow(
          item: items[i],
          isUndoing: undoInProgressIds.contains(items[i].id),
          onUndo: onUndo,
        ),
      );
    }

    if (!expand) {
      return GlassCard(
        backgroundColor: AppColors.surface,
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
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.item,
    required this.isUndoing,
    required this.onUndo,
  });

  final AdminActivityResponse item;
  final bool isUndoing;
  final Future<void> Function(int id) onUndo;

  @override
  Widget build(BuildContext context) {
    final canUndo = item.canUndo && !item.isUndone;
    final remaining =
        DateTimeUtils.toLocal(item.undoAvailableUntil).difference(DateTime.now());
    final isAddAction = item.actionType.toLowerCase() == 'add';
    final accentColor = isAddAction ? AppColors.success : AppColors.warning;
    final actionIcon = isAddAction ? LucideIcons.plus : LucideIcons.trash2;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              actionIcon,
              size: 16,
              color: accentColor,
            ),
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
                Text(
                  '${item.adminUsername} • ${_timeAgo(item.createdAt)}',
                  style: AppTextStyles.caption,
                ),
                if (canUndo) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Undo: jos ${remaining.inMinutes.clamp(0, 59)} min',
                    style: AppTextStyles.caption.copyWith(
                      color: accentColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (item.isUndone)
            _Badge(text: 'Ponisteno', color: AppColors.success)
          else if (canUndo)
            SizedBox(
              height: 30,
              child: OutlinedButton(
                onPressed: isUndoing ? null : () => onUndo(item.id),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: isUndoing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Undo',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
          else
            _Badge(text: 'Isteklo', color: AppColors.textMuted),
        ],
      ),
    );
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

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
