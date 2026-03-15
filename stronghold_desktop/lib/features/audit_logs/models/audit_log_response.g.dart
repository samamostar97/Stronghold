// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogResponse _$AuditLogResponseFromJson(Map<String, dynamic> json) =>
    _AuditLogResponse(
      id: (json['id'] as num).toInt(),
      adminUserId: (json['adminUserId'] as num).toInt(),
      adminUsername: json['adminUsername'] as String,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: (json['entityId'] as num).toInt(),
      entitySnapshot: json['entitySnapshot'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      canUndoUntil: DateTime.parse(json['canUndoUntil'] as String),
      canUndo: json['canUndo'] as bool,
    );

Map<String, dynamic> _$AuditLogResponseToJson(_AuditLogResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adminUserId': instance.adminUserId,
      'adminUsername': instance.adminUsername,
      'action': instance.action,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'entitySnapshot': instance.entitySnapshot,
      'createdAt': instance.createdAt.toIso8601String(),
      'canUndoUntil': instance.canUndoUntil.toIso8601String(),
      'canUndo': instance.canUndo,
    };

_PagedAuditLogResponse _$PagedAuditLogResponseFromJson(
  Map<String, dynamic> json,
) => _PagedAuditLogResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => AuditLogResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedAuditLogResponseToJson(
  _PagedAuditLogResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
