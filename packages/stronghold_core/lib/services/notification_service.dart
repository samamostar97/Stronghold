import '../api/api_client.dart';
import '../models/responses/notification_response.dart';

/// Notification service for admin notification management.
class NotificationService {
  final ApiClient _client;
  static const String _basePath = '/api/notifications';

  NotificationService(this._client);

  /// Get count of unread notifications
  Future<int> getUnreadCount() async {
    return _client.get<int>(
      '$_basePath/unread-count',
      parser: (json) => json as int,
    );
  }

  /// Get recent notifications
  Future<List<NotificationDTO>> getRecent({int count = 20}) async {
    return _client.get<List<NotificationDTO>>(
      '$_basePath/recent',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int id) async {
    await _client.patch<void>(
      '$_basePath/$id/read',
      parser: (_) {},
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _client.patch<void>(
      '$_basePath/read-all',
      parser: (_) {},
    );
  }
}
