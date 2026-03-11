// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupplierResponse _$SupplierResponseFromJson(Map<String, dynamic> json) =>
    _SupplierResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupplierResponseToJson(_SupplierResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'website': instance.website,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_PagedSupplierResponse _$PagedSupplierResponseFromJson(
  Map<String, dynamic> json,
) => _PagedSupplierResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SupplierResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedSupplierResponseToJson(
  _PagedSupplierResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
