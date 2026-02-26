import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/order_provider.dart';
import '../providers/list_state.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/orders/order_details_dialog.dart';
import '../widgets/orders/orders_table.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  String? _selectedSort;
  OrderStatus? _selectedStatus;

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
      ref.read(orderListProvider.notifier).setSearch(s.isEmpty ? '' : s);
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
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'cancel-order'),
        );
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
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'deliver-order'),
        );
      }
    }
  }

  void _onSortChanged(String? v) {
    setState(() => _selectedSort = v);
    final notifier = ref.read(orderListProvider.notifier);
    switch (v) {
      case 'date_desc':
        notifier.setOrderBy('date', descending: true);
      case 'date_asc':
        notifier.setOrderBy('date', descending: false);
      case 'amount_desc':
        notifier.setOrderBy('amount', descending: true);
      case 'amount_asc':
        notifier.setOrderBy('amount', descending: false);
      case 'status_asc':
        notifier.setOrderBy('status', descending: false);
      case 'status_desc':
        notifier.setOrderBy('status', descending: true);
      case 'user_asc':
        notifier.setOrderBy('user', descending: false);
      case 'user_desc':
        notifier.setOrderBy('user', descending: true);
      default:
        notifier.setOrderBy(null, descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content
        Expanded(
          child: _OrdersContent(
            state: state,
            searchController: _searchController,
            selectedSort: _selectedSort,
            selectedStatus: _selectedStatus,
            onSortChanged: _onSortChanged,
            onStatusChanged: (v) {
              setState(() => _selectedStatus = v);
              ref.read(orderListProvider.notifier).setStatus(v);
            },
            onRefresh: ref.read(orderListProvider.notifier).refresh,
            onViewDetails: _viewDetails,
            onPageChanged: ref.read(orderListProvider.notifier).goToPage,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.state,
    required this.searchController,
    required this.selectedSort,
    required this.selectedStatus,
    required this.onSortChanged,
    required this.onStatusChanged,
    required this.onRefresh,
    required this.onViewDetails,
    required this.onPageChanged,
  });

  final ListState<OrderResponse, OrderQueryFilter> state;
  final TextEditingController searchController;
  final String? selectedSort;
  final OrderStatus? selectedStatus;
  final ValueChanged<String?> onSortChanged;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final VoidCallback onRefresh;
  final ValueChanged<OrderResponse> onViewDetails;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(w),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(double width) {
    final sort = _SortDropdown(
      value: selectedSort,
      onChanged: onSortChanged,
    );
    final status = _StatusDropdown(
      value: selectedStatus,
      onChanged: onStatusChanged,
    );

    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchInput(
            controller: searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili email-u...',
          ),
          const SizedBox(height: AppSpacing.md),
          sort,
          const SizedBox(height: AppSpacing.md),
          status,
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: SearchInput(
            controller: searchController,
            onSubmitted: (_) {},
            hintText: 'Pretrazi po korisniku ili email-u...',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        sort,
        const SizedBox(width: AppSpacing.lg),
        status,
      ],
    );
  }

  Widget _buildBody() {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [1, 3, 2, 2, 2, 2]);
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.error!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton.text(
                text: 'Pokusaj ponovo', onPressed: onRefresh),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child:
              OrdersTable(orders: state.items, onViewDetails: onViewDetails),
        ),
        const SizedBox(height: AppSpacing.lg),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text('Sortiraj', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium,
          icon: Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 16,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(
                value: 'date_desc', child: Text('Datum (najnovije)')),
            DropdownMenuItem(
                value: 'date_asc', child: Text('Datum (najstarije)')),
            DropdownMenuItem(
                value: 'amount_desc', child: Text('Iznos (opadajuce)')),
            DropdownMenuItem(
                value: 'amount_asc', child: Text('Iznos (rastuce)')),
            DropdownMenuItem(
                value: 'status_asc', child: Text('Status (A-Z)')),
            DropdownMenuItem(
                value: 'status_desc', child: Text('Status (Z-A)')),
            DropdownMenuItem(
                value: 'user_asc', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(
                value: 'user_desc', child: Text('Korisnik (Z-A)')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final OrderStatus? value;
  final ValueChanged<OrderStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus?>(
          value: value,
          hint: Text('Status', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium,
          icon:
              Icon(LucideIcons.filter, color: AppColors.textMuted, size: 16),
          items: const [
            DropdownMenuItem<OrderStatus?>(value: null, child: Text('Svi')),
            DropdownMenuItem<OrderStatus?>(
                value: OrderStatus.processing, child: Text('U obradi')),
            DropdownMenuItem<OrderStatus?>(
                value: OrderStatus.delivered, child: Text('Isporuceno')),
            DropdownMenuItem<OrderStatus?>(
                value: OrderStatus.cancelled, child: Text('Otkazano')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
