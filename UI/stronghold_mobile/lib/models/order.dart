/// Narudzba u historiji - polja koja mobile prikazuje kupcu.
class Order {
  final int id;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
        items: (json['items'] as List)
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class OrderItem {
  final int supplementId;
  final String supplementName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.supplementId,
    required this.supplementName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        supplementId: json['supplementId'] as int,
        supplementName: json['supplementName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}
