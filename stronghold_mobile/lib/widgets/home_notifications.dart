import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/notification_provider.dart';
import 'glass_card.dart';

class HomeNotifications extends ConsumerStatefulWidget {
  const HomeNotifications({super.key});

  @override
  ConsumerState<HomeNotifications> createState() => _HomeNotificationsState();
}

class _HomeNotificationsState extends ConsumerState<HomeNotifications> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(userNotificationProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotificationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Obavijesti', style: AppTextStyles.headingSm),
            if (state.unreadCount > 0)
              GestureDetector(
                onTap: () =>
                    ref.read(userNotificationProvider.notifier).markAllAsRead(),
                child: Text(
                  'Oznaci sve',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.isLoading && state.items.isEmpty)
          _loadingState()
        else if (state.items.isEmpty)
          _emptyState()
        else
          ...state.items.take(5).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _notificationCard(n),
              )),
      ],
    );
  }

  Widget _loadingState() {
    return const GlassCard(
      child: SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(LucideIcons.bellOff,
                size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            'Nemate novih obavijesti',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(NotificationDTO notification) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return GlassCard(
      onTap: notification.isRead
          ? null
          : () => ref
              .read(userNotificationProvider.notifier)
              .markAsRead(notification.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: notification.isRead
                            ? AppTextStyles.bodyMd
                            : AppTextStyles.bodyBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: AppTextStyles.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  timeAgo,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order_confirmed':
        return LucideIcons.packageCheck;
      case 'order_delivered':
        return LucideIcons.truck;
      case 'order_cancelled':
        return LucideIcons.packageX;
      case 'appointment_reminder':
        return LucideIcons.calendarClock;
      case 'membership_expiry':
        return LucideIcons.alertTriangle;
      default:
        return LucideIcons.bell;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'order_confirmed':
        return AppColors.success;
      case 'order_delivered':
        return AppColors.primary;
      case 'order_cancelled':
        return AppColors.error;
      case 'appointment_reminder':
        return AppColors.secondary;
      case 'membership_expiry':
        return AppColors.warning;
      default:
        return AppColors.accent;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
