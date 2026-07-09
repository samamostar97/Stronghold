/// Korpa sa servera - server je izvor istine.
class Cart {
  final List<CartItem> items;
  final double total;

  Cart({required this.items, required this.total});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        items: (json['items'] as List)
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
      );

  factory Cart.empty() => Cart(items: [], total: 0);
}

class CartItem {
  final int supplementId;
  final String name;
  final double price;
  final int stockQuantity;
  final bool hasImage;
  final int quantity;
  final double subtotal;

  CartItem({
    required this.supplementId,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.hasImage,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        supplementId: json['supplementId'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        stockQuantity: json['stockQuantity'] as int,
        hasImage: json['hasImage'] as bool,
        quantity: json['quantity'] as int,
        subtotal: (json['subtotal'] as num).toDouble(),
      );
}
