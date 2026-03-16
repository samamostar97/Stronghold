import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/notifications_repository.dart';
import '../models/notification_response.dart';

final notificationsRepositoryProvider =
    Provider((ref) => NotificationsRepository());

final unreadCountProvider = FutureProvider<int>((ref) async {
  try {
    final response =
        await ApiClient.instance.get('/notifications/unread-count');
    return response.data as int? ?? 0;
  } on DioException {
    return 0;
  }
});

final notificationsProvider =
    FutureProvider.autoDispose<PagedNotificationResponse>((ref) async {
  final repo = ref.read(notificationsRepositoryProvider);
  return repo.getNotifications();
});
