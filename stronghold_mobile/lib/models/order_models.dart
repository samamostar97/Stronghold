class OrderItem {
  final int id;
  final String supplementName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.supplementName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      supplementName: json['supplementName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final double totalAmount;
  final DateTime purchaseDate;
  final int status;
  final String statusName;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.totalAmount,
    required this.purchaseDate,
    required this.status,
    required this.statusName,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['orderItems'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      status: json['status'] as int,
      statusName: json['statusName'] as String,
      orderItems: itemsList
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String get statusNameBosnian {
    switch (statusName.toLowerCase()) {
      case 'processing':
        return 'U obradi';
      case 'delivered':
        return 'Dostavljeno';
      case 'cancelled':
        return 'Otkazano';
      default:
        return statusName;
    }
  }
}
