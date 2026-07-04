import 'package:flutter/foundation.dart';

import '../models/supplement.dart';

class CartItem {
  final Supplement supplement;
  int quantity;

  CartItem({required this.supplement, required this.quantity});

  double get subtotal => supplement.price * quantity;
}

/// Korpa zivi u memoriji aplikacije - narudzba nastaje tek nakon placanja.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  void add(Supplement supplement, {int quantity = 1}) {
    final existing = _items.where((i) => i.supplement.id == supplement.id).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(supplement: supplement, quantity: quantity));
    }
    notifyListeners();
  }

  void setQuantity(int supplementId, int quantity) {
    final item = _items.where((i) => i.supplement.id == supplementId).firstOrNull;
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(item);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(int supplementId) {
    _items.removeWhere((i) => i.supplement.id == supplementId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
