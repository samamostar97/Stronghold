// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    _OrderResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String,
      status: json['status'] as String,
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => OrderItemResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OrderResponseToJson(_OrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'totalAmount': instance.totalAmount,
      'deliveryAddress': instance.deliveryAddress,
      'status': instance.status,
      'stripePaymentIntentId': instance.stripePaymentIntentId,
      'clientSecret': instance.clientSecret,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
    };

_OrderItemResponse _$OrderItemResponseFromJson(Map<String, dynamic> json) =>
    _OrderItemResponse(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemResponseToJson(_OrderItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'productImageUrl': instance.productImageUrl,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'subtotal': instance.subtotal,
    };

_PagedOrderResponse _$PagedOrderResponseFromJson(Map<String, dynamic> json) =>
    _PagedOrderResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
    );

Map<String, dynamic> _$PagedOrderResponseToJson(_PagedOrderResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
    };
