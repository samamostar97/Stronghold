import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';
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
                    leading: Icon(
                      _iconFor(notification.type),
                      color: notification.isRead
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            notification.isRead ? FontWeight.normal : FontWeight.bold,
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
