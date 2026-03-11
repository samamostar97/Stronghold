// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppointmentResponse _$AppointmentResponseFromJson(Map<String, dynamic> json) =>
    _AppointmentResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      staffId: (json['staffId'] as num).toInt(),
      staffName: json['staffName'] as String,
      staffType: json['staffType'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppointmentResponseToJson(
  _AppointmentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'staffId': instance.staffId,
  'staffName': instance.staffName,
  'staffType': instance.staffType,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'status': instance.status,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};

_PagedAppointmentResponse _$PagedAppointmentResponseFromJson(
  Map<String, dynamic> json,
) => _PagedAppointmentResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => AppointmentResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedAppointmentResponseToJson(
  _PagedAppointmentResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
