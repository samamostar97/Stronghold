import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final items = cartState.items;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Korpa', style: AppTextStyles.headingMd.copyWith(color: Colors.white))),
              if (items.isNotEmpty)
                GestureDetector(
                  onTap: () => cartNotifier.clear(),
                  child: Text(
                    'Isprazni',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.error),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: (items.isEmpty
                ? AppEmptyState(
                    icon: LucideIcons.shoppingCart,
                    title: 'Korpa je prazna',
                    subtitle: 'Dodajte suplemente iz prodavnice',
                    actionLabel: 'Idi u prodavnicu',
                    onAction: () {
                      context.go('/shop');
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: CartItemCard(
                          item: item,
                          onQuantityChanged: (q) =>
                              cartNotifier.updateQuantity(
                                  item.supplement.id, q),
                          onRemove: () =>
                              cartNotifier.removeItem(item.supplement.id),
                        ),
                      );
                    },
                  ))
                .animate(delay: 100.ms)
                .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve,
                ),
          ),
          if (items.isNotEmpty)
            OrderSummaryCard(
              totalAmount: cartState.totalAmount,
              onCheckout: () => context.push('/checkout'),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: Motion.smooth,
                  curve: Motion.curve,
                ),
        ]),
      ),
    );
  }
}
