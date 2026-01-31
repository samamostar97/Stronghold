/// Order status enum matching backend OrderStatus
enum OrderStatus {
  processing,
  delivered,
}

/// Helper extension for OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'U obradi';
      case OrderStatus.delivered:
        return 'Dostavljeno';
    }
  }

  static OrderStatus fromInt(int value) {
    switch (value) {
      case 0:
        return OrderStatus.processing;
      case 1:
        return OrderStatus.delivered;
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
      default:
        return OrderStatus.processing;
    }
  }
}

/// Order item DTO matching backend OrderItemDTO
class OrderItemDTO {
  final int id;
  final int supplementId;
  final String supplementName;
  final int quantity;
  final double unitPrice;

  double get totalPrice => quantity * unitPrice;

  const OrderItemDTO({
    required this.id,
    required this.supplementId,
    required this.supplementName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemDTO.fromJson(Map<String, dynamic> json) {
    return OrderItemDTO(
      id: (json['id'] ?? 0) as int,
      supplementId: (json['supplementId'] ?? 0) as int,
      supplementName: (json['supplementName'] ?? '') as String,
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble(),
    );
  }
}

/// Order DTO matching backend OrdersDTO
class OrderDTO {
  final int id;
  final int userId;
  final String userFullName;
  final String userEmail;
  final double totalAmount;
  final DateTime purchaseDate;
  final OrderStatus status;
  final String statusName;
  final String? stripePaymentId;
  final List<OrderItemDTO> orderItems;

  const OrderDTO({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.totalAmount,
    required this.purchaseDate,
    required this.status,
    required this.statusName,
    this.stripePaymentId,
    required this.orderItems,
  });

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['orderItems'] as List<dynamic>?)
            ?.map((e) => OrderItemDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <OrderItemDTO>[];

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

    return OrderDTO(
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
      orderItems: itemsList,
    );
  }
}

/// Paged result for orders
class PagedOrdersResult {
  final List<OrderDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedOrdersResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedOrdersResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => OrderDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <OrderDTO>[];

    return PagedOrdersResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
