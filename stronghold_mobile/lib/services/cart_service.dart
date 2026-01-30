import 'package:flutter/foundation.dart';
import '../models/cart_models.dart';
import '../models/supplement_models.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  static const int maxQuantity = 99;

  void addItem(Supplement supplement) {
    final existingIndex = _items.indexWhere((item) => item.supplement.id == supplement.id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity < maxQuantity) {
        _items[existingIndex].quantity++;
      }
    } else {
      _items.add(CartItem(supplement: supplement));
    }
    notifyListeners();
  }

  void removeItem(int supplementId) {
    _items.removeWhere((item) => item.supplement.id == supplementId);
    notifyListeners();
  }

  void updateQuantity(int supplementId, int quantity) {
    if (quantity <= 0) {
      removeItem(supplementId);
      return;
    }
    if (quantity > maxQuantity) return;
    final existingIndex = _items.indexWhere((item) => item.supplement.id == supplementId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
