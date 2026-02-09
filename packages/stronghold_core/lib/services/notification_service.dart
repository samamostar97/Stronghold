import '../api/api_client.dart';
import '../models/responses/notification_response.dart';

/// Notification service for admin and user notification management.
class NotificationService {
  final ApiClient _client;
  static const String _basePath = '/api/notifications';

  NotificationService(this._client);

  // Admin methods

  /// Get count of unread admin notifications
  Future<int> getUnreadCount() async {
    return _client.get<int>(
      '$_basePath/unread-count',
      parser: (json) => json as int,
    );
  }

  /// Get recent admin notifications
  Future<List<NotificationDTO>> getRecent({int count = 20}) async {
    return _client.get<List<NotificationDTO>>(
      '$_basePath/recent',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mark a single admin notification as read
  Future<void> markAsRead(int id) async {
    await _client.patch<void>(
      '$_basePath/$id/read',
      parser: (_) {},
    );
  }

  /// Mark all admin notifications as read
  Future<void> markAllAsRead() async {
    await _client.patch<void>(
      '$_basePath/read-all',
      parser: (_) {},
    );
  }

  // User methods

  /// Get count of unread user notifications
  Future<int> getMyUnreadCount() async {
    return _client.get<int>(
      '$_basePath/my/unread-count',
      parser: (json) => json as int,
    );
  }

  /// Get recent user notifications
  Future<List<NotificationDTO>> getMyNotifications({int count = 20}) async {
    return _client.get<List<NotificationDTO>>(
      '$_basePath/my',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mark a single user notification as read
  Future<void> markMyAsRead(int id) async {
    await _client.patch<void>(
      '$_basePath/my/$id/read',
      parser: (_) {},
    );
  }

  /// Mark all user notifications as read
  Future<void> markAllMyAsRead() async {
    await _client.patch<void>(
      '$_basePath/my/read-all',
      parser: (_) {},
    );
  }
}
