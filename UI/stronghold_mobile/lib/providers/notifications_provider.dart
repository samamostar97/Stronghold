import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';
import '../models/paged_result.dart';
import '../utils/api_client.dart';

/// Notifikacije se automatski osvjezavaju pollingom - bez rucnog refresha.
class NotificationsProvider extends ChangeNotifier {
  static const Duration _pollInterval = Duration(seconds: 30);

  final ApiClient _api;
  Timer? _pollTimer;

  NotificationsProvider(this._api);

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  void startPolling() {
    stopPolling();
    refresh();
    _pollTimer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.get('/api/notifications/my', query: {'page': '1', 'pageSize': '50'}),
        _api.get('/api/notifications/my/unread-count'),
      ]);
      _notifications = PagedResult.fromJson(
        results[0] as Map<String, dynamic>,
        NotificationItem.fromJson,
      ).items;
      _unreadCount = results[1] as int;
    } on ApiException {
      // polling ne smije rusiti UI - sljedeci ciklus pokusava ponovo
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    await _api.put('/api/notifications/$id/read');
    await refresh();
  }

  Future<void> markAllRead() async {
    await _api.put('/api/notifications/read-all');
    await refresh();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
