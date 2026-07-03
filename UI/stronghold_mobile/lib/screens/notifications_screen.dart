import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) => switch (type) {
        'MembershipExpiry' => Icons.card_membership,
        'UpcomingSeminar' => Icons.school_outlined,
        'OrderStatusChanged' => Icons.local_shipping_outlined,
        'AppointmentStatusChanged' => Icons.event_outlined,
        'PaymentConfirmed' => Icons.payments_outlined,
        _ => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikacije'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => context.read<NotificationsProvider>().markAllRead(),
              child: const Text('Označi sve pročitanim'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: provider.notifications.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Nemate notifikacija.')),
                ],
              )
            : ListView.separated(
                itemCount: provider.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return ListTile(
                    tileColor: notification.isRead ? null : Colors.white,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? AppTheme.background
                            : AppTheme.navyTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(notification.type),
                        size: 20,
                        color: notification.isRead
                            ? AppTheme.textSecondary
                            : AppTheme.navy,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.dateTime(notification.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    onTap: notification.isRead
                        ? null
                        : () => context
                            .read<NotificationsProvider>()
                            .markRead(notification.id),
                  );
                },
              ),
      ),
    );
  }
}
