// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    _ProductResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      supplierId: (json['supplierId'] as num).toInt(),
      supplierName: json['supplierName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProductResponseToJson(_ProductResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'stockQuantity': instance.stockQuantity,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_PagedProductResponse _$PagedProductResponseFromJson(
  Map<String, dynamic> json,
) => _PagedProductResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedProductResponseToJson(
  _PagedProductResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
