import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';

/// Checkout: pregled korpe -> adresa dostave -> Stripe PaymentSheet (in-app placanje).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _streetController;
  int? _selectedCityId;
  List<City> _cities = [];
  String? _error;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    // adresa dostave se predpopunjava sa profila ako postoji
    final profile = context.read<ProfileProvider>().profile;
    _streetController = TextEditingController(text: profile?.streetAddress ?? '');
    _selectedCityId = profile?.cityId;
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await context.read<ProfileProvider>().loadCities();
    if (mounted) setState(() => _cities = cities);
  }

  @override
  void dispose() {
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    setState(() => _processing = true);

    try {
      // 1. server racuna iznos i kreira PaymentIntent
      final intent = await orders.createPaymentIntent(
        items: [
          for (final item in cart.items)
            {'supplementId': item.supplement.id, 'quantity': item.quantity},
        ],
        deliveryStreet: _streetController.text.trim(),
        deliveryCityId: _selectedCityId!,
      );

      // 2. in-app placanje kroz Stripe PaymentSheet
      Stripe.publishableKey = intent['publishableKey'] as String;
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent['clientSecret'] as String,
          merchantDisplayName: 'Stronghold',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 3. server verifikuje status kod Stripe-a i tek onda kreira narudzbu
      final order =
          await orders.confirmOrder(intent['paymentIntentId'] as String);

      cart.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Plaćeno'),
          content: Text(
            'Narudžba #${order.id} u iznosu od ${Formatters.money(order.totalAmount)} '
            'je uspješno plaćena i u obradi je.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Nastavi kupovinu'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on StripeException catch (e) {
      setState(() => _error = e.error.code == FailureCode.Canceled
          ? 'Plaćanje je prekinuto.'
          : (e.error.localizedMessage ?? 'Plaćanje nije uspjelo. Pokušajte ponovo.'));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Plaćanje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pregled narudžbe',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        for (final item in cart.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        '${item.supplement.name} x ${item.quantity}')),
                                Text(Formatters.money(item.subtotal)),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Ukupno',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              Formatters.money(cart.total),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Adresa dostave',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Ulica i broj',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite ulicu i broj za dostavu.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'Grad',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final city in _cities)
                      DropdownMenuItem(value: city.id, child: Text(city.name)),
                  ],
                  validator: (value) =>
                      value == null ? 'Odaberite grad dostave.' : null,
                  onChanged: (value) => setState(() => _selectedCityId = value),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _processing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Plati ${Formatters.money(cart.total)}'),
                  ),
                  onPressed: _processing || cart.isEmpty ? null : _pay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
