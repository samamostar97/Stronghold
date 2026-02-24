import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/cart_models.dart';
import 'api_providers.dart';

/// Checkout state
class CheckoutState {
  final CheckoutResponse? response;
  final bool isLoading;
  final String? error;

  const CheckoutState({
    this.response,
    this.isLoading = false,
    this.error,
  });

  CheckoutState copyWith({
    CheckoutResponse? response,
    bool? isLoading,
    String? error,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return CheckoutState(
      response: clearResponse ? null : (response ?? this.response),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Checkout notifier - handles Stripe payment flow
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final UserOrderService _service;

  CheckoutNotifier(this._service) : super(const CheckoutState());

  /// Create payment intent for cart items
  Future<CheckoutResponse> createPaymentIntent(List<CartItem> items) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cartItems = items.map((item) => {
            'supplementId': item.supplement.id,
            'quantity': item.quantity,
          }).toList();

      final response = await _service.checkout(cartItems);
      state = state.copyWith(response: response, isLoading: false);
      return response;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom kreiranja placanja',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Confirm order after successful payment
  Future<void> confirmOrder(String paymentIntentId, List<CartItem> items) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cartItems = items.map((item) => {
            'supplementId': item.supplement.id,
            'quantity': item.quantity,
          }).toList();

      await _service.confirmOrder(paymentIntentId, cartItems);
      state = state.copyWith(isLoading: false, clearResponse: true);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom potvrde narudzbe',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Clear checkout state
  void clear() {
    state = const CheckoutState();
  }
}

/// Checkout provider
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final client = ref.watch(apiClientProvider);
  return CheckoutNotifier(UserOrderService(client));
});
