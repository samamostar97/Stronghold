import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/appointment_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';

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

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
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
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    ref.read(userNotificationProvider.notifier).load();
    ref.read(myAppointmentsProvider.notifier).load();
  }

  List<_NotifItem> _buildNotificationList() {
    final items = <_NotifItem>[];
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));

    // Backend notifications
    final backendState = ref.watch(userNotificationProvider);
    for (final n in backendState.items) {
      items.add(_NotifItem(
        type: n.type,
        title: n.title,
        message: n.message,
        date: n.createdAt,
        backendId: n.id,
        isRead: n.isRead,
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
            message:
                '${m.packageName} istice ${DateFormat('dd.MM.yyyy').format(m.endDate)}',
            date: m.endDate,
          ));
        }
      }
    });

    // Sort: unread first, then by date descending
    items.sort((a, b) {
      if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
      return b.date.compareTo(a.date);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final backendState = ref.watch(userNotificationProvider);
    final items = _buildNotificationList();
    final hasUnread = items.any((n) => !n.isRead && n.backendId != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: AppSpacing.touchTarget,
                      height: AppSpacing.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.arrowLeft,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      'Obavijesti',
                      style: AppTextStyles.headingMd
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  if (hasUnread)
                    GestureDetector(
                      onTap: () => ref
                          .read(userNotificationProvider.notifier)
                          .markAllAsRead(),
                      child: Text(
                        'Oznaci sve',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: backendState.isLoading && items.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : items.isEmpty
                      ? _emptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, i) => _notificationCard(items[i])
                              .animate(delay: (50 * i).ms)
                              .fadeIn(
                                  duration: Motion.smooth, curve: Motion.curve)
                              .slideY(
                                begin: 0.04,
                                end: 0,
                                duration: Motion.smooth,
                                curve: Motion.curve,
                              ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.navyBlue.withValues(alpha: 0.5)),
            ),
            child:
                const Icon(LucideIcons.bellOff, size: 28, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nemate obavijesti',
            style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ovdje cete vidjeti sve obavijesti',
            style: AppTextStyles.bodySm
                .copyWith(color: Colors.white.withValues(alpha: 0.5)),
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
              border: Border.all(
                  color: AppColors.navyBlue.withValues(alpha: 0.5),
                  width: 0.5),
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
                            ? AppTextStyles.bodyMd
                                .copyWith(color: Colors.white)
                            : AppTextStyles.bodyBold
                                .copyWith(color: Colors.white),
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
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white70),
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
    if (item.backendId == null) {
      final now = DateTime.now();
      final diff = item.date.difference(now);
      if (diff.inDays == 0) return 'Danas';
      if (diff.inDays == 1) return 'Sutra';
      return 'Za ${diff.inDays} dana';
    }

    final now = DateTime.now();
    final diff = now.difference(item.date);
    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd.MM.yyyy').format(item.date);
  }
}
