/// Checkout response with Stripe payment intent details
class CheckoutResponse {
  final String clientSecret;
  final String paymentIntentId;
  final double totalAmount;

  const CheckoutResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.totalAmount,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}
