import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/checkout_address_step.dart';
import '../widgets/checkout_confirmation_step.dart';
import '../widgets/checkout_payment_step.dart';
import '../widgets/checkout_review_step.dart';
import '../widgets/checkout_step_indicator.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;
  String? _errorMessage;
  AddressResponse? _address;

  static const _stepTitles = [
    'Pregled narudzbe',
    'Adresa dostave',
    'Placanje',
    'Potvrda',
  ];

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      _errorMessage = null;
    });
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final cartState = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    // Fetch address for snapshot
    final addressAsync = ref.read(addressProvider);
    _address = addressAsync.valueOrNull;

    String? paymentIntentId;
    bool paymentSucceeded = false;

    try {
      // Step 1: Create PaymentIntent
      final checkoutResponse = await checkoutNotifier.createPaymentIntent(
        cartState.items,
      );
      paymentIntentId = checkoutResponse.paymentIntentId;

      // Step 2: Initialize Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: checkoutResponse.clientSecret,
          merchantDisplayName: 'Stronghold',
        ),
      );

      // Step 3: Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();
      paymentSucceeded = true;

      // Step 4: Confirm order on backend
      await checkoutNotifier.confirmOrder(
        checkoutResponse.paymentIntentId,
        cartState.items,
      );

      // Step 5: Clear cart, go to confirmation
      cartNotifier.clear();

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 3;
        });
      }
    } on StripeException catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (e.error.code != FailureCode.Canceled) {
            _errorMessage =
                e.error.localizedMessage ?? 'Greska prilikom placanja';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (paymentSucceeded) {
            _errorMessage =
                'Uplata je uspjela, ali kreiranje narudzbe nije. '
                'Kontaktirajte podrsku sa ID: $paymentIntentId';
          } else {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _appBar(),
            const SizedBox(height: AppSpacing.md),
            // Step indicator
            CheckoutStepIndicator(currentStep: _currentStep),
            const SizedBox(height: AppSpacing.lg),
            // Step content
            Expanded(child: _buildStep(cartState)),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        0,
      ),
      child: Row(
        children: [
          if (_currentStep < 3) ...[
            GestureDetector(
              onTap: _isProcessing
                  ? null
                  : () {
                      if (_currentStep == 0) {
                        Navigator.pop(context);
                      } else {
                        _goToStep(_currentStep - 1);
                      }
                    },
              child: Container(
                width: AppSpacing.touchTarget,
                height: AppSpacing.touchTarget,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(LucideIcons.arrowLeft,
                    color: AppColors.textPrimary, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Text(
              _stepTitles[_currentStep],
              style: AppTextStyles.headingMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(CartState cartState) {
    switch (_currentStep) {
      case 0:
        return CheckoutReviewStep(
          items: cartState.items,
          total: cartState.totalAmount,
          onBack: () => Navigator.pop(context),
          onNext: () => _goToStep(1),
        );
      case 1:
        return CheckoutAddressStep(
          onBack: () => _goToStep(0),
          onNext: () {
            // Refetch address before going to payment
            final addr = ref.read(addressProvider).valueOrNull;
            setState(() => _address = addr);
            _goToStep(2);
          },
        );
      case 2:
        return CheckoutPaymentStep(
          items: cartState.items,
          total: cartState.totalAmount,
          address: _address,
          isProcessing: _isProcessing,
          error: _errorMessage,
          onBack: () => _goToStep(1),
          onPay: _handlePayment,
        );
      case 3:
        return CheckoutConfirmationStep(address: _address);
      default:
        return const SizedBox.shrink();
    }
  }
}
