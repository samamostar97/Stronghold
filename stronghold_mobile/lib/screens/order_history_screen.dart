import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/order_provider.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/order_history_card.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState
    extends ConsumerState<OrderHistoryScreen> {
  final Set<int> _expandedOrders = {};
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(
        () => ref.read(orderListProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = ref.read(orderListProvider);
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !s.isLoading &&
        s.hasNextPage) {
      ref.read(orderListProvider.notifier).nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: Text('Historija narudzbi',
                      style: AppTextStyles.headingMd)),
            ]),
          ),
          Expanded(child: _body(state)),
        ]),
      ),
    );
  }

  Widget _body(OrderListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoadingIndicator();
    }
    if (state.error != null && state.items.isEmpty) {
      return AppErrorState(
        message: state.error!,
        onRetry: () =>
            ref.read(orderListProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.shoppingBag,
        title: 'Nemate narudzbi',
        subtitle:
            'Vasa historija narudzbi ce se prikazati ovdje',
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(orderListProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding),
        itemCount: state.items.length +
            (state.isLoading && state.items.isNotEmpty ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            );
          }
          final order = state.items[i];
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppSpacing.md),
            child: OrderHistoryCard(
              order: order,
              isExpanded:
                  _expandedOrders.contains(order.id),
              onToggle: () => setState(() {
                if (_expandedOrders.contains(order.id)) {
                  _expandedOrders.remove(order.id);
                } else {
                  _expandedOrders.add(order.id);
                }
              }),
            ),
          );
        },
      ),
    );
  }
}
