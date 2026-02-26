import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import 'notification_popup.dart';

/// Aether top bar for admin dashboard shell.
class AdminTopBar extends ConsumerWidget {
  const AdminTopBar({
    super.key,
    required this.title,
    this.onNavigateToOrders,
  });

  final String title;
  final VoidCallback? onNavigateToOrders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.headingMd.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const Spacer(),
          _NotificationBell(onNavigateToOrders: onNavigateToOrders),
        ],
      ),
    );
  }
}

class _NotificationBell extends ConsumerStatefulWidget {
  const _NotificationBell({this.onNavigateToOrders});

  final VoidCallback? onNavigateToOrders;

  @override
  ConsumerState<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<_NotificationBell> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _togglePopup() {
    if (_overlayEntry != null) {
      _closePopup();
      return;
    }
    _openPopup();
  }

  void _openPopup() {
    ref.read(notificationProvider.notifier).fetchRecent();

    _overlayEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closePopup,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: 380,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(-340, 48),
                child: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(notificationProvider);
                    return NotificationPopup(
                      notifications: state.recent,
                      isLoading: state.isLoading,
                      onMarkAsRead: (id) =>
                          ref.read(notificationProvider.notifier).markAsRead(id),
                      onMarkAllAsRead: () =>
                          ref.read(notificationProvider.notifier).markAllAsRead(),
                      onTapNotification: (n) {
                        _closePopup();
                        if ((n.type == 'new_order' ||
                                n.type == 'order_cancelled') &&
                            widget.onNavigateToOrders != null) {
                          widget.onNavigateToOrders!();
                        }
                      },
                      onClose: _closePopup,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _closePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(
        notificationProvider.select((s) => s.unreadCount));

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: AppSpacing.smallRadius,
              color: Colors.transparent,
            ),
            child: IconButton(
              icon: Icon(
                LucideIcons.bell,
                size: 20,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: _togglePopup,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: AppSpacing.badgeRadius,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

