import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(apiClientProvider));
});

/// Notification state
class NotificationState {
  final int unreadCount;
  final List<NotificationDTO> recent;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.unreadCount = 0,
    this.recent = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    int? unreadCount,
    List<NotificationDTO>? recent,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      recent: recent ?? this.recent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notification notifier with polling
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;
  Timer? _pollTimer;

  NotificationNotifier(this._service) : super(const NotificationState());

  /// Start polling for unread count every 30 seconds
  void startPolling() {
    // Fetch immediately
    fetchUnreadCount();
    // Then poll every 30s
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchUnreadCount();
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Fetch unread count only (lightweight)
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      if (mounted) {
        state = state.copyWith(unreadCount: count);
      }
    } catch (_) {
      // Silently fail - polling shouldn't disrupt UX
    }
  }

  /// Fetch recent notifications (called when popup opens)
  Future<void> fetchRecent() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.getRecent();
      if (mounted) {
        state = state.copyWith(
          recent: items,
          isLoading: false,
          unreadCount: items.where((n) => !n.isRead).length,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      if (mounted) {
        final updated = state.recent
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList();
        state = state.copyWith(
          recent: updated,
          unreadCount: updated.where((n) => !n.isRead).length,
        );
      }
    } catch (_) {}
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      if (mounted) {
        final updated =
            state.recent.map((n) => n.copyWith(isRead: true)).toList();
        state = state.copyWith(recent: updated, unreadCount: 0);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
