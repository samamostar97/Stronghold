import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplement_models.dart';
import '../models/cart_models.dart';

/// Cart state
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;
}

/// Cart notifier - manages local shopping cart
class CartNotifier extends StateNotifier<CartState> {
  static const int maxQuantity = 99;

  CartNotifier() : super(const CartState());

  /// Add item to cart
  void addItem(Supplement supplement) {
    final existingIndex = state.items.indexWhere(
      (item) => item.supplement.id == supplement.id,
    );

    if (existingIndex >= 0) {
      if (state.items[existingIndex].quantity < maxQuantity) {
        final newItems = List<CartItem>.from(state.items);
        newItems[existingIndex].quantity++;
        state = CartState(items: newItems);
      }
    } else {
      state = CartState(items: [...state.items, CartItem(supplement: supplement)]);
    }
  }

  /// Remove item from cart
  void removeItem(int supplementId) {
    final newItems = state.items
        .where((item) => item.supplement.id != supplementId)
        .toList();
    state = CartState(items: newItems);
  }

  /// Update item quantity
  void updateQuantity(int supplementId, int quantity) {
    if (quantity <= 0) {
      removeItem(supplementId);
      return;
    }
    if (quantity > maxQuantity) return;

    final existingIndex = state.items.indexWhere(
      (item) => item.supplement.id == supplementId,
    );

    if (existingIndex >= 0) {
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex].quantity = quantity;
      state = CartState(items: newItems);
    }
  }

  /// Clear cart
  void clear() {
    state = const CartState();
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
