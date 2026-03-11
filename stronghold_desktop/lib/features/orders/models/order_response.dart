import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_response.freezed.dart';
part 'order_response.g.dart';

@freezed
abstract class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required int id,
    required int userId,
    required String userName,
    required double totalAmount,
    required String deliveryAddress,
    required String status,
    String? stripePaymentIntentId,
    String? clientSecret,
    required DateTime createdAt,
    @Default([]) List<OrderItemResponse> items,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
}

@freezed
abstract class OrderItemResponse with _$OrderItemResponse {
  const factory OrderItemResponse({
    required int id,
    required int productId,
    required String productName,
    String? productImageUrl,
    required int quantity,
    required double unitPrice,
    required double subtotal,
  }) = _OrderItemResponse;

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderItemResponseFromJson(json);
}

@freezed
abstract class PagedOrderResponse with _$PagedOrderResponse {
  const factory PagedOrderResponse({
    required List<OrderResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedOrderResponse;

  factory PagedOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedOrderResponseFromJson(json);
}
