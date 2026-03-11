// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_visit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GymVisitResponse _$GymVisitResponseFromJson(Map<String, dynamic> json) =>
    _GymVisitResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userFullName: json['userFullName'] as String,
      username: json['username'] as String,
      checkInAt: DateTime.parse(json['checkInAt'] as String),
      checkOutAt: json['checkOutAt'] == null
          ? null
          : DateTime.parse(json['checkOutAt'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GymVisitResponseToJson(_GymVisitResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'username': instance.username,
      'checkInAt': instance.checkInAt.toIso8601String(),
      'checkOutAt': instance.checkOutAt?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
    };

_PagedGymVisitResponse _$PagedGymVisitResponseFromJson(
  Map<String, dynamic> json,
) => _PagedGymVisitResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => GymVisitResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedGymVisitResponseToJson(
  _PagedGymVisitResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
