/// Order status enum matching backend OrderStatus
enum OrderStatus {
  processing,
  delivered,
  cancelled,
}

/// Helper extension for OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'U obradi';
      case OrderStatus.delivered:
        return 'Dostavljeno';
      case OrderStatus.cancelled:
        return 'Otkazano';
    }
  }

  static OrderStatus fromInt(int value) {
    switch (value) {
      case 0:
        return OrderStatus.processing;
      case 1:
        return OrderStatus.delivered;
      case 2:
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }
}

/// Matches backend OrderItemResponse
class OrderItemResponse {
  final int id;
  final int supplementId;
  final String supplementName;
  final int quantity;
  final double unitPrice;

  double get totalPrice => quantity * unitPrice;

  const OrderItemResponse({
    required this.id,
    required this.supplementId,
    required this.supplementName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: (json['id'] ?? 0) as int,
      supplementId: (json['supplementId'] ?? 0) as int,
      supplementName: (json['supplementName'] ?? '') as String,
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble(),
    );
  }
}

/// Matches backend OrderResponse
class OrderResponse {
  final int id;
  final int userId;
  final String userFullName;
  final String userEmail;
  final double totalAmount;
  final DateTime purchaseDate;
  final OrderStatus status;
  final String statusName;
  final String? stripePaymentId;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final List<OrderItemResponse> orderItems;

  const OrderResponse({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.totalAmount,
    required this.purchaseDate,
    required this.status,
    required this.statusName,
    this.stripePaymentId,
    this.cancelledAt,
    this.cancellationReason,
    required this.orderItems,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['orderItems'] as List<dynamic>?)
            ?.map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <OrderItemResponse>[];

    // Parse status - can be int or string
    OrderStatus parsedStatus;
    final statusValue = json['status'];
    if (statusValue is int) {
      parsedStatus = OrderStatusExtension.fromInt(statusValue);
    } else if (statusValue is String) {
      parsedStatus = OrderStatusExtension.fromString(statusValue);
    } else {
      parsedStatus = OrderStatus.processing;
    }

    return OrderResponse(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      userFullName: (json['userFullName'] ?? '') as String,
      userEmail: (json['userEmail'] ?? '') as String,
      totalAmount: ((json['totalAmount'] ?? 0) as num).toDouble(),
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.now(),
      status: parsedStatus,
      statusName: (json['statusName'] ?? '') as String,
      stripePaymentId: json['stripePaymentId'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      orderItems: itemsList,
    );
  }
}
