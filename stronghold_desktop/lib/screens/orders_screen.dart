import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/order_provider.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/order_details_dialog.dart';
import '../widgets/orders_table.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/success_animation.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      final s = _searchController.text.trim();
      ref.read(orderListProvider.notifier).setSearch(s.isEmpty ? null : s);
    });
  }

  Future<void> _viewDetails(OrderResponse order) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => OrderDetailsDialog(
        order: order,
        onMarkDelivered: () async {
          Navigator.of(ctx).pop();
          await _markDelivered(order);
        },
        onCancelOrder: (reason) async {
          await _cancelOrder(order, reason);
        },
      ),
    );
  }

  Future<void> _cancelOrder(OrderResponse order, String? reason) async {
    if (order.status != OrderStatus.processing) return;
    try {
      await ref
          .read(orderListProvider.notifier)
          .cancelOrder(order.id, reason: reason);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'cancel-order'));
      }
    }
  }

  Future<void> _markDelivered(OrderResponse order) async {
    if (order.status == OrderStatus.delivered) return;
    try {
      await ref.read(orderListProvider.notifier).markAsDelivered(order.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'deliver-order'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);
    final notifier = ref.read(orderListProvider.notifier);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Upravljanje narudzbama', style: AppTextStyles.headingMd),
              const SizedBox(height: AppSpacing.xxl),
              _searchBar(constraints),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _content(state, notifier)),
            ],
          ),
        ),
      );
    });
  }

  Widget _searchBar(BoxConstraints c) {
    final sort = _sortDropdown();
    if (c.maxWidth < 600) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SearchInput(
            controller: _searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili email-u...'),
        const SizedBox(height: AppSpacing.md),
        sort,
      ]);
    }
    return Row(children: [
      Expanded(
          child: SearchInput(
              controller: _searchController,
              onSubmitted: (_) {},
              hintText: 'Pretrazi po korisniku ili email-u...')),
      const SizedBox(width: AppSpacing.lg),
      sort,
    ]);
  }

  Widget _sortDropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: _selectedSort,
            hint: Text('Sortiraj', style: AppTextStyles.bodyMd),
            dropdownColor: AppColors.surfaceSolid,
            style: AppTextStyles.bodyBold,
            icon: Icon(LucideIcons.arrowUpDown,
                color: AppColors.textMuted, size: 16),
            items: const [
              DropdownMenuItem(value: null, child: Text('Zadano')),
              DropdownMenuItem(
                  value: 'date', child: Text('Datum (najnovije)')),
              DropdownMenuItem(
                  value: 'amount', child: Text('Iznos (opadajuce)')),
              DropdownMenuItem(value: 'status', child: Text('Status')),
            ],
            onChanged: (v) {
              setState(() => _selectedSort = v);
              ref.read(orderListProvider.notifier).setOrderBy(v);
            },
          ),
        ),
      );

  Widget _content(
      ListState<OrderResponse, OrderQueryFilter> state,
      OrderListNotifier notifier) {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [1, 3, 2, 2, 2, 2]);
    }
    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          Text(state.error!,
              style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(text: 'Pokusaj ponovo', onTap: notifier.refresh),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
          child: OrdersTable(
              orders: state.items, onViewDetails: _viewDetails)),
      const SizedBox(height: AppSpacing.lg),
      PaginationControls(
        currentPage: state.currentPage,
        totalPages: state.totalPages,
        totalCount: state.totalCount,
        onPageChanged: notifier.goToPage,
      ),
    ]);
  }
}
