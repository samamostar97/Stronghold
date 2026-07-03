class Order {
  final int id;
  final int userId;
  final String userFullName;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final String stripePaymentIntentId;
  final String deliveryStreet;
  final String deliveryCityName;
  final String? cancellationReason;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.stripePaymentIntentId,
    required this.deliveryStreet,
    required this.deliveryCityName,
    this.cancellationReason,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        userId: json['userId'] as int,
        userFullName: json['userFullName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
        stripePaymentIntentId: json['stripePaymentIntentId'] as String,
        deliveryStreet: json['deliveryStreet'] as String,
        deliveryCityName: json['deliveryCityName'] as String,
        cancellationReason: json['cancellationReason'] as String?,
        items: (json['items'] as List)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class OrderItem {
  final String supplementName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.supplementName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        supplementName: json['supplementName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}
