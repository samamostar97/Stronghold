// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_membership_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserMembershipResponse _$UserMembershipResponseFromJson(
  Map<String, dynamic> json,
) => _UserMembershipResponse(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String,
  membershipPackageId: (json['membershipPackageId'] as num).toInt(),
  membershipPackageName: json['membershipPackageName'] as String,
  membershipPackagePrice: (json['membershipPackagePrice'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserMembershipResponseToJson(
  _UserMembershipResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'membershipPackageId': instance.membershipPackageId,
  'membershipPackageName': instance.membershipPackageName,
  'membershipPackagePrice': instance.membershipPackagePrice,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

_PagedUserMembershipResponse _$PagedUserMembershipResponseFromJson(
  Map<String, dynamic> json,
) => _PagedUserMembershipResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => UserMembershipResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedUserMembershipResponseToJson(
  _PagedUserMembershipResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
