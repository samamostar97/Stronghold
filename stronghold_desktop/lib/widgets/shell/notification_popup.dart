import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Dropdown popup for notification list, shown below the bell icon.
class NotificationPopup extends StatelessWidget {
  const NotificationPopup({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.onMarkAsRead,
    required this.onMarkAllAsRead,
    required this.onTapNotification,
    required this.onClose,
  });

  final List<NotificationDTO> notifications;
  final bool isLoading;
  final ValueChanged<int> onMarkAsRead;
  final VoidCallback onMarkAllAsRead;
  final ValueChanged<NotificationDTO> onTapNotification;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hasUnread = notifications.any((n) => !n.isRead);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 380,
        constraints: const BoxConstraints(maxHeight: 460),
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Text('Obavjestenja', style: AppTextStyles.headingSm),
                  const Spacer(),
                  if (hasUnread)
                    TextButton(
                      onPressed: onMarkAllAsRead,
                      child: Text('Oznaci sve',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.primary)),
                    ),
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        size: 16, color: AppColors.textMuted),
                    onPressed: onClose,
                    splashRadius: 16,
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Content
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            else if (notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(LucideIcons.bellOff,
                        size: 32, color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.md),
                    Text('Nema obavjestenja',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: AppColors.border, height: 1),
                  itemBuilder: (_, i) => _NotificationTile(
                    notification: notifications[i],
                    onTap: () {
                      if (!notifications[i].isRead) {
                        onMarkAsRead(notifications[i].id);
                      }
                      onTapNotification(notifications[i]);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationDTO notification;
  final VoidCallback onTap;

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_order':
        return LucideIcons.shoppingBag;
      case 'order_cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.bell;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'new_order':
        return AppColors.success;
      case 'order_cancelled':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(DateTime dt) {
    final localDt = DateTimeUtils.toLocal(dt);
    final diff = DateTime.now().difference(localDt);
    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd.MM.').format(localDt);
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final typeColor = _colorForType(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          // Unread: subtle left border accent
          border: isUnread
              ? Border(left: BorderSide(color: AppColors.primary, width: 3))
              : null,
          color: isUnread ? AppColors.surfaceHover : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_iconForType(notification.type),
                  size: 16, color: typeColor),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: isUnread
                              ? AppTextStyles.bodyBold
                              : AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(_timeAgo(notification.createdAt),
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySm.copyWith(
                      color:
                          isUnread ? AppColors.textSecondary : AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread dot
            if (isUnread) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
