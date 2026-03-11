// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffResponse _$StaffResponseFromJson(Map<String, dynamic> json) =>
    _StaffResponse(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      staffType: json['staffType'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$StaffResponseToJson(_StaffResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'bio': instance.bio,
      'profileImageUrl': instance.profileImageUrl,
      'staffType': instance.staffType,
      'isActive': instance.isActive,
    };

_PagedStaffResponse _$PagedStaffResponseFromJson(Map<String, dynamic> json) =>
    _PagedStaffResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => StaffResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
    );

Map<String, dynamic> _$PagedStaffResponseToJson(_PagedStaffResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
    };
