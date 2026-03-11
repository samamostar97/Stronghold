// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductCategoryResponse _$ProductCategoryResponseFromJson(
  Map<String, dynamic> json,
) => _ProductCategoryResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProductCategoryResponseToJson(
  _ProductCategoryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};
