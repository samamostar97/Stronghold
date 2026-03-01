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
import '../widgets/shared/surface_card.dart';

class _NotifItem {
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final int? backendId;
  final bool isRead;
  final String route;

  const _NotifItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.route,
    this.backendId,
    this.isRead = false,
  });
}

class _NotifSection {
  final String title;
  final List<_NotifItem> items;

  const _NotifSection({required this.title, required this.items});
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
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() {
    ref.read(userNotificationProvider.notifier).load();
    ref.read(myAppointmentsProvider.notifier).load();
  }

  List<_NotifItem> _buildItems({
    required UserNotificationState backendState,
    required MyAppointmentsState appointmentState,
    required List<MembershipPaymentResponse> memberships,
  }) {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    final items = <_NotifItem>[];

    for (final notification in backendState.items) {
      items.add(
        _NotifItem(
          type: notification.type,
          title: notification.title,
          message: notification.message,
          date: notification.createdAt,
          backendId: notification.id,
          isRead: notification.isRead,
          route: _routeFromBackendNotification(
            notification.type,
            notification.relatedEntityType,
          ),
        ),
      );
    }

    for (final appointment in appointmentState.items) {
      if (appointment.appointmentDate.isAfter(now) &&
          appointment.appointmentDate.isBefore(sevenDaysFromNow)) {
        final professional =
            appointment.trainerName ?? appointment.nutritionistName ?? '';
        final dateLabel = DateFormat(
          'dd.MM',
          'bs',
        ).format(appointment.appointmentDate);
        final timeLabel = DateFormat(
          'HH:mm',
        ).format(appointment.appointmentDate);
        final daysUntil = appointment.appointmentDate.difference(now).inDays;

        items.add(
          _NotifItem(
            type: 'appointment_reminder',
            title: daysUntil == 0
                ? 'Termin danas'
                : (daysUntil == 1
                      ? 'Termin sutra'
                      : 'Termin za $daysUntil dana'),
            message: '$professional - $dateLabel u $timeLabel',
            date: appointment.appointmentDate,
            route: '/appointments',
            isRead: true,
          ),
        );
      }
    }

    for (final membership in memberships) {
      final daysLeft = membership.endDate.difference(now).inDays;
      if (membership.isActive && daysLeft >= 0 && daysLeft <= 7) {
        items.add(
          _NotifItem(
            type: 'membership_expiry',
            title: daysLeft == 0
                ? 'Clanarina istice danas'
                : (daysLeft == 1
                      ? 'Clanarina istice sutra'
                      : 'Clanarina istice za $daysLeft dana'),
            message:
                '${membership.packageName} istice ${DateFormat('dd.MM.yyyy').format(membership.endDate)}',
            date: membership.endDate,
            route: '/profile',
            isRead: true,
          ),
        );
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  List<_NotifSection> _groupItems(List<_NotifItem> items) {
    final grouped = <String, List<_NotifItem>>{};

    for (final item in items) {
      final key = _sectionLabel(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries
        .map((entry) => _NotifSection(title: entry.key, items: entry.value))
        .toList();
  }

  String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(itemDay).inDays;

    if (diff == 0) return 'Danas';
    if (diff == 1) return 'Juce';
    if (diff < 7) {
      final weekday = DateFormat('EEEE', 'bs').format(date);
      return weekday[0].toUpperCase() + weekday.substring(1);
    }
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _routeFromBackendNotification(String type, String? relatedEntityType) {
    final normalizedType = type.toLowerCase();
    final normalizedEntity = (relatedEntityType ?? '').toLowerCase();

    if (normalizedType.contains('order') ||
        normalizedEntity.contains('order')) {
      return '/orders';
    }
    if (normalizedType.contains('appointment') ||
        normalizedEntity.contains('appointment')) {
      return '/appointments';
    }
    if (normalizedType.contains('review') ||
        normalizedEntity.contains('review')) {
      return '/reviews';
    }
    if (normalizedType.contains('seminar') ||
        normalizedEntity.contains('seminar')) {
      return '/seminars';
    }
    if (normalizedType.contains('membership')) {
      return '/profile';
    }
    return '/home';
  }

  Future<void> _openNotification(_NotifItem item) async {
    if (!item.isRead && item.backendId != null) {
      await ref
          .read(userNotificationProvider.notifier)
          .markAsRead(item.backendId!);
    }
    if (!mounted) return;
    _openRoute(item.route);
  }

  void _openRoute(String route) {
    if (route == '/home' ||
        route == '/appointments' ||
        route == '/shop' ||
        route == '/profile') {
      context.go(route);
      return;
    }
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final backendState = ref.watch(userNotificationProvider);
    final appointmentState = ref.watch(myAppointmentsProvider);
    final membershipState = ref.watch(membershipHistoryProvider);
    final memberships = membershipState.asData?.value ?? [];

    final items = _buildItems(
      backendState: backendState,
      appointmentState: appointmentState,
      memberships: memberships,
    );

    final sections = _groupItems(items);
    final hasUnreadBackend = backendState.unreadCount > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: AppSpacing.touchTarget,
                      height: AppSpacing.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Obavijesti', style: AppTextStyles.headingMd),
                        const SizedBox(height: 2),
                        Text(
                          '${items.length} stavki',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (hasUnreadBackend)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: InkWell(
                        onTap: () => ref
                            .read(userNotificationProvider.notifier)
                            .markAllAsRead(),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Oznaci sve',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      children: [
                        for (var i = 0; i < sections.length; i++) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              top: i == 0 ? 0 : AppSpacing.lg,
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(
                              sections[i].title,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          for (var j = 0; j < sections[i].items.length; j++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _notificationCard(sections[i].items[j])
                                  .animate(delay: (40 * (i + j)).ms)
                                  .fadeIn(
                                    duration: Motion.smooth,
                                    curve: Motion.curve,
                                  )
                                  .slideY(
                                    begin: 0.03,
                                    end: 0,
                                    duration: Motion.smooth,
                                    curve: Motion.curve,
                                  ),
                            ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                      ],
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
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              LucideIcons.bellOff,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Nemate obavijesti', style: AppTextStyles.bodyBold),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ovdje cete vidjeti novosti i podsjetnike.',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(_NotifItem item) {
    final icon = _iconForType(item.type);
    final color = _colorForType(item.type);
    final timeLabel = _formatTimeLabel(item);

    return SurfaceCard(
      onTap: () => _openNotification(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.26)),
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
                        item.title,
                        style: item.isRead
                            ? AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textPrimary,
                              )
                            : AppTextStyles.bodyBold.copyWith(
                                color: AppColors.textPrimary,
                              ),
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
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.message,
                  style: AppTextStyles.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(timeLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'order_confirmed' => LucideIcons.packageCheck,
      'order_delivered' => LucideIcons.truck,
      'order_cancelled' => LucideIcons.packageX,
      'appointment_reminder' => LucideIcons.calendarClock,
      'membership_expiry' => LucideIcons.alertTriangle,
      _ => LucideIcons.bell,
    };
  }

  Color _colorForType(String type) {
    return switch (type) {
      'order_confirmed' => AppColors.success,
      'order_delivered' => AppColors.primary,
      'order_cancelled' => AppColors.error,
      'appointment_reminder' => AppColors.secondary,
      'membership_expiry' => AppColors.warning,
      _ => AppColors.accent,
    };
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
