import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_response.freezed.dart';
part 'audit_log_response.g.dart';

@freezed
abstract class AuditLogResponse with _$AuditLogResponse {
  const factory AuditLogResponse({
    required int id,
    required int adminUserId,
    required String adminUsername,
    required String action,
    required String entityType,
    required int entityId,
    required String entitySnapshot,
    required DateTime createdAt,
    required DateTime canUndoUntil,
    required bool canUndo,
  }) = _AuditLogResponse;

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) =>
      _$AuditLogResponseFromJson(json);
}

@freezed
abstract class PagedAuditLogResponse with _$PagedAuditLogResponse {
  const factory PagedAuditLogResponse({
    required List<AuditLogResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedAuditLogResponse;

  factory PagedAuditLogResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedAuditLogResponseFromJson(json);
}
