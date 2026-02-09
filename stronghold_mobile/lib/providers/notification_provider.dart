import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// User notification state
class UserNotificationState {
  final List<NotificationDTO> items;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const UserNotificationState({
    this.items = const <NotificationDTO>[],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  UserNotificationState copyWith({
    List<NotificationDTO>? items,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return UserNotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User notification notifier
class UserNotificationNotifier extends StateNotifier<UserNotificationState> {
  final NotificationService _service;

  UserNotificationNotifier(this._service) : super(const UserNotificationState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _service.getMyNotifications();
      final unread = await _service.getMyUnreadCount();
      state = state.copyWith(
        items: notifications,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markMyAsRead(id);
      final updated = state.items.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(items: updated, unreadCount: unread);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllMyAsRead();
      final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(items: updated, unreadCount: 0);
    } catch (_) {}
  }
}

final userNotificationProvider =
    StateNotifierProvider<UserNotificationNotifier, UserNotificationState>((ref) {
  final client = ref.watch(apiClientProvider);
  final service = NotificationService(client);
  return UserNotificationNotifier(service);
});
