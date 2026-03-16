import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_response.freezed.dart';
part 'notification_response.g.dart';

@freezed
abstract class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required int id,
    required String title,
    required String message,
    required String type,
    required int referenceId,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}

@freezed
abstract class PagedNotificationResponse with _$PagedNotificationResponse {
  const factory PagedNotificationResponse({
    required List<NotificationResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedNotificationResponse;

  factory PagedNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedNotificationResponseFromJson(json);
}
