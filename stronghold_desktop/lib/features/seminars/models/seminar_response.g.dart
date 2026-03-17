// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seminar_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeminarResponse _$SeminarResponseFromJson(Map<String, dynamic> json) =>
    _SeminarResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      lecturer: json['lecturer'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      maxCapacity: (json['maxCapacity'] as num).toInt(),
      registeredCount: (json['registeredCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SeminarResponseToJson(_SeminarResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'lecturer': instance.lecturer,
      'startDate': instance.startDate.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'maxCapacity': instance.maxCapacity,
      'registeredCount': instance.registeredCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_PagedSeminarResponse _$PagedSeminarResponseFromJson(
  Map<String, dynamic> json,
) => _PagedSeminarResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SeminarResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedSeminarResponseToJson(
  _PagedSeminarResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};

_SeminarRegistrationResponse _$SeminarRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => _SeminarRegistrationResponse(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String,
  userEmail: json['userEmail'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SeminarRegistrationResponseToJson(
  _SeminarRegistrationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'userEmail': instance.userEmail,
  'createdAt': instance.createdAt.toIso8601String(),
};
