import 'supplement_models.dart';

class CartItem {
  final Supplement supplement;
  int quantity;

  CartItem({
    required this.supplement,
    this.quantity = 1,
  });

  double get totalPrice => supplement.price * quantity;
}
