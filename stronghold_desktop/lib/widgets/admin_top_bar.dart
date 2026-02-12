import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/notification_provider.dart';
import '../screens/login_screen.dart';
import 'avatar_widget.dart';
import 'notification_popup.dart';

/// Persistent top bar for the admin dashboard shell.
///
/// Displays the current page title, notification bell with badge,
/// and the admin profile dropdown.
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSolid,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Page title
          Text(
            title,
            style: AppTextStyles.headingMd,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const Spacer(),

          // Notification bell
          _NotificationBell(onNavigateToOrders: onNavigateToOrders),
          const SizedBox(width: AppSpacing.sm),

          // Profile dropdown
          _ProfileDropdown(onLogout: () => _logout(context)),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
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
    // Fetch latest notifications when opening
    ref.read(notificationProvider.notifier).fetchRecent();

    _overlayEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closePopup,
        child: Stack(
          children: [
            // Invisible barrier to catch taps outside
            Positioned.fill(child: Container(color: Colors.transparent)),
            // Popup positioned below bell
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
                        // Navigate to orders if it's an order notification
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
          IconButton(
            icon: const Icon(
              LucideIcons.bell,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: _togglePopup,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
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

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      color: AppColors.surfaceSolid,
      onSelected: (value) {
        if (value == 'logout') onLogout();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(LucideIcons.logOut,
                  color: AppColors.error, size: 18),
              const SizedBox(width: AppSpacing.md),
              Text('Odjavi se',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: const AvatarWidget(initials: 'AD', size: 36),
    );
  }
}
