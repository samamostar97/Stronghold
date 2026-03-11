// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_package_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembershipPackageResponse _$MembershipPackageResponseFromJson(
  Map<String, dynamic> json,
) => _MembershipPackageResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MembershipPackageResponseToJson(
  _MembershipPackageResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'createdAt': instance.createdAt.toIso8601String(),
};

_PagedMembershipPackageResponse _$PagedMembershipPackageResponseFromJson(
  Map<String, dynamic> json,
) => _PagedMembershipPackageResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => MembershipPackageResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedMembershipPackageResponseToJson(
  _PagedMembershipPackageResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
