import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/appointment_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import 'package:stronghold_core/stronghold_core.dart';

/// Unified notification item for display
class _NotifItem {
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final int? backendId;
  final bool isRead;

  const _NotifItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    this.backendId,
    this.isRead = false,
  });
}

class HomeNotifications extends ConsumerStatefulWidget {
  const HomeNotifications({super.key});

  @override
  ConsumerState<HomeNotifications> createState() => _HomeNotificationsState();
}

class _HomeNotificationsState extends ConsumerState<HomeNotifications>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() {
    ref.read(userNotificationProvider.notifier).load();
    ref.read(myAppointmentsProvider.notifier).load();
  }

  List<_NotifItem> _buildNotificationList() {
    final items = <_NotifItem>[];
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));

    // Backend notifications (only unread)
    final backendState = ref.watch(userNotificationProvider);
    for (final n in backendState.items) {
      if (n.isRead) continue;
      items.add(_NotifItem(
        type: n.type,
        title: n.title,
        message: n.message,
        date: n.createdAt,
        backendId: n.id,
        isRead: false,
      ));
    }

    // Upcoming appointments within 7 days
    final appointmentState = ref.watch(myAppointmentsProvider);
    for (final a in appointmentState.items) {
      if (a.appointmentDate.isAfter(now) &&
          a.appointmentDate.isBefore(sevenDaysFromNow)) {
        final daysUntil = a.appointmentDate.difference(now).inDays;
        final professional = a.trainerName ?? a.nutritionistName ?? '';
        final dateStr = DateFormat('dd.MM', 'bs').format(a.appointmentDate);
        final timeStr = DateFormat('HH:mm').format(a.appointmentDate);

        String dayLabel;
        if (daysUntil == 0) {
          dayLabel = 'danas';
        } else if (daysUntil == 1) {
          dayLabel = 'sutra';
        } else {
          dayLabel = 'za $daysUntil dana';
        }

        items.add(_NotifItem(
          type: 'appointment_reminder',
          title: 'Termin $dayLabel',
          message: '$professional - $dateStr u $timeStr',
          date: a.appointmentDate,
        ));
      }
    }

    // Membership expiring within 7 days
    final membershipAsync = ref.watch(membershipHistoryProvider);
    membershipAsync.whenData((payments) {
      final active = payments.where((p) => p.isActive).toList();
      for (final m in active) {
        final daysLeft = m.endDate.difference(now).inDays;
        if (daysLeft <= 7 && daysLeft >= 0) {
          String dayLabel;
          if (daysLeft == 0) {
            dayLabel = 'danas';
          } else if (daysLeft == 1) {
            dayLabel = 'sutra';
          } else {
            dayLabel = 'za $daysLeft dana';
          }

          items.add(_NotifItem(
            type: 'membership_expiry',
            title: 'Clanarina istice $dayLabel',
            message: '${m.packageName} istice ${DateFormat('dd.MM.yyyy').format(m.endDate)}',
            date: m.endDate,
          ));
        }
      }
    });

    // Sort: unread first, then by date (newest/soonest first)
    items.sort((a, b) {
      if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
      return a.date.compareTo(b.date);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final backendState = ref.watch(userNotificationProvider);
    final items = _buildNotificationList();
    final hasUnread = items.any((n) => !n.isRead && n.backendId != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Obavijesti', style: AppTextStyles.headingSm.copyWith(color: Colors.white)),
            if (hasUnread)
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
        if (backendState.isLoading && items.isEmpty)
          _loadingState()
        else if (items.isEmpty)
          _emptyState()
        else
          ...items.take(6).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _notificationCard(n),
              )),
      ],
    );
  }

  Widget _loadingState() {
    return const GlassCard(
      backgroundColor: Color(0x33FFFFFF),
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
      backgroundColor: const Color(0x33FFFFFF),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.5), width: 0.5),
            ),
            child: const Icon(LucideIcons.bellOff,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            'Nemate novih obavijesti',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(_NotifItem item) {
    final icon = _iconForType(item.type);
    final color = _colorForType(item.type);
    final timeLabel = _formatTimeLabel(item);

    return GlassCard(
      backgroundColor: const Color(0x33FFFFFF),
      onTap: (!item.isRead && item.backendId != null)
          ? () => ref
              .read(userNotificationProvider.notifier)
              .markAsRead(item.backendId!)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
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
                        item.title,
                        style: item.isRead
                            ? AppTextStyles.bodyMd.copyWith(color: Colors.white)
                            : AppTextStyles.bodyBold.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isRead && item.backendId != null)
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
                  item.message,
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  timeLabel,
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white70),
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

  String _formatTimeLabel(_NotifItem item) {
    // For local (computed) notifications, show relative future time
    if (item.backendId == null) {
      final now = DateTime.now();
      final diff = item.date.difference(now);
      if (diff.inDays == 0) return 'Danas';
      if (diff.inDays == 1) return 'Sutra';
      return 'Za ${diff.inDays} dana';
    }

    // For backend notifications, show relative past time
    final now = DateTime.now();
    final diff = now.difference(item.date);
    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd.MM.yyyy').format(item.date);
  }
}
