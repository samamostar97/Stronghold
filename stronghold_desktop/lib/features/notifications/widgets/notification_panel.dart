import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/notification_response.dart';
import '../providers/notification_provider.dart';

class NotificationPanel extends ConsumerStatefulWidget {
  const NotificationPanel({super.key});

  @override
  ConsumerState<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends ConsumerState<NotificationPanel> {
  Future<void> _markAllAsRead() async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.markAllAsRead();
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (_) {}
  }

  Future<void> _onNotificationTap(NotificationResponse notification) async {
    if (!notification.isRead) {
      try {
        final repo = ref.read(notificationsRepositoryProvider);
        await repo.markAsRead(notification.id);
        ref.invalidate(unreadCountProvider);
        ref.invalidate(notificationsProvider);
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    final route = _routeForNotification(notification);
    if (route != null) {
      context.go(route);
    }
  }

  String? _routeForNotification(NotificationResponse notification) {
    switch (notification.type) {
      case 'NewOrder':
        return '/orders';
      case 'NewAppointment':
        return '/staff/appointments';
      default:
        return null;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Prije ${diff.inHours}h';
    if (diff.inDays < 7) return 'Prije ${diff.inDays}d';
    return '${date.day}.${date.month}.${date.year}.';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'NewOrder':
        return Icons.shopping_bag_outlined;
      case 'NewAppointment':
        return Icons.calendar_today_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'NewOrder':
        return AppColors.info;
      case 'NewAppointment':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Text('Notifikacije', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: _markAllAsRead,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(
                    'Oznaci sve kao procitano',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

          // Content
          notificationsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
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
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(notificationsProvider),
                  child: Text('Pokusaj ponovo',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ),
            ),
            data: (data) {
              if (data.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Nema notifikacija', style: AppTextStyles.bodySmall),
                  ),
                );
              }

              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: data.items.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
                  itemBuilder: (context, index) {
                    final n = data.items[index];
                    return _NotificationTile(
                      notification: n,
                      icon: _iconForType(n.type),
                      color: _colorForType(n.type),
                      timeAgo: _formatDate(n.createdAt),
                      onTap: () => _onNotificationTap(n),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final NotificationResponse notification;
  final IconData icon;
  final Color color;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.color,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isUnread = !widget.notification.isRead;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: _hovering
              ? Colors.white.withValues(alpha: 0.03)
              : isUnread
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notification.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.notification.message,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
