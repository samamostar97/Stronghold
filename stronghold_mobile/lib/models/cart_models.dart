import 'package:stronghold_core/stronghold_core.dart';

class CartItem {
  final SupplementResponse supplement;
  int quantity;

  CartItem({
    required this.supplement,
    this.quantity = 1,
  });

  double get totalPrice => supplement.price * quantity;
}
