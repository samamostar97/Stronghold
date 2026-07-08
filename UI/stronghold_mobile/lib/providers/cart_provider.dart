import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/supplement.dart';
import '../utils/api_client.dart';

/// Korpa zivi na serveru - lokalno stanje se uvijek zamjenjuje odgovorom API-ja.
class CartProvider extends ChangeNotifier {
  final ApiClient _api;

  CartProvider(this._api);

  Cart _cart = Cart.empty();
  bool _loading = false;

  List<CartItem> get items => List.unmodifiable(_cart.items);
  bool get isEmpty => _cart.items.isEmpty;
  int get itemCount => _cart.items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _cart.total;
  bool get loading => _loading;

  Future<void> load() async {
    // odmah isprazni prikaz - korpa prethodnog korisnika ne smije bljesnuti
    _cart = Cart.empty();
    _loading = true;
    notifyListeners();
    try {
      _apply(await _api.get('/api/cart'));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Supplement supplement, {int quantity = 1}) async {
    _apply(await _api.post('/api/cart/items', body: {
      'supplementId': supplement.id,
      'quantity': quantity,
    }));
  }

  Future<void> setQuantity(int supplementId, int quantity) async {
    if (quantity <= 0) {
      await remove(supplementId);
      return;
    }
    _apply(await _api.put('/api/cart/items/$supplementId',
        body: {'quantity': quantity}));
  }

  Future<void> remove(int supplementId) async {
    _apply(await _api.delete('/api/cart/items/$supplementId'));
  }

  Future<void> clear() async {
    _apply(await _api.delete('/api/cart'));
  }

  /// Lokalni reset bez API poziva - poslije checkouta server vec isprazni korpu.
  void resetLocal() {
    _cart = Cart.empty();
    notifyListeners();
  }

  void _apply(dynamic data) {
    _cart = Cart.fromJson(data as Map<String, dynamic>);
    notifyListeners();
  }
}
