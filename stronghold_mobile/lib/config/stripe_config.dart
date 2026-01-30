class StripeConfig {
  // Pass via --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
  // Or update the defaultValue below for local development
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51SvL7dBlrIi9HZmrpay9Tog3KFDvHRhlqN79lwDSk6eEY28g9AX5Lh9jCo73WpvKoy1uOPishDeoIkj2rFCy20wL00kgziPzD3',
  );
}
