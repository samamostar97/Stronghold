import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/list_state.dart';
import '../providers/order_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/orders/order_details_dialog.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/small_button.dart';
import '../widgets/shared/success_animation.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);
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
      final value = _searchController.text.trim();
      ref
          .read(orderListProvider.notifier)
          .setSearch(value.isEmpty ? '' : value);
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

  void _onSortChanged(String? value) {
    setState(() => _selectedSort = value);

    final notifier = ref.read(orderListProvider.notifier);
    switch (value) {
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

    return Padding(
      padding: AppSpacing.desktopPage,
      child:
          _OrdersPanel(
                state: state,
                searchController: _searchController,
                selectedSort: _selectedSort,
                selectedStatus: _selectedStatus,
                onSortChanged: _onSortChanged,
                onStatusChanged: (status) {
                  setState(() => _selectedStatus = status);
                  ref.read(orderListProvider.notifier).setStatus(status);
                },
                onRefresh: ref.read(orderListProvider.notifier).refresh,
                onOnlyActive: () {
                  setState(() => _selectedStatus = OrderStatus.processing);
                  ref
                      .read(orderListProvider.notifier)
                      .setStatus(OrderStatus.processing);
                },
                onViewDetails: _viewDetails,
                onPageChanged: ref.read(orderListProvider.notifier).goToPage,
              )
              .animate(delay: 160.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.03,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
    );
  }
}

class _OrdersPanel extends StatelessWidget {
  const _OrdersPanel({
    required this.state,
    required this.searchController,
    required this.selectedSort,
    required this.selectedStatus,
    required this.onSortChanged,
    required this.onStatusChanged,
    required this.onRefresh,
    required this.onOnlyActive,
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
  final VoidCallback onOnlyActive;
  final ValueChanged<OrderResponse> onViewDetails;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filters(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _filters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sort = _SortDropdown(
          value: selectedSort,
          onChanged: onSortChanged,
        );
        final status = _StatusDropdown(
          value: selectedStatus,
          onChanged: onStatusChanged,
        );

        if (constraints.maxWidth < 820) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchInput(
                controller: searchController,
                onSubmitted: (_) {},
                hintText: 'Pretrazi po korisniku ili email-u...',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: sort),
                  const SizedBox(width: 10),
                  Expanded(child: status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SmallButton(
                text: 'Osvjezi rezultate',
                color: AppColors.secondary,
                onTap: onRefresh,
              ),
              const SizedBox(height: AppSpacing.sm),
              SmallButton(
                text: 'Samo aktivne',
                color: AppColors.primary,
                onTap: onOnlyActive,
              ),
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
            const SizedBox(width: 10),
            sort,
            const SizedBox(width: 10),
            status,
            const SizedBox(width: 10),
            SmallButton(
              text: 'Osvjezi',
              color: AppColors.secondary,
              onTap: onRefresh,
            ),
            const SizedBox(width: 8),
            SmallButton(
              text: 'Samo aktivne',
              color: AppColors.primary,
              onTap: onOnlyActive,
            ),
          ],
        );
      },
    );
  }

  Widget _body() {
    if (state.isLoading && state.items.isEmpty) {
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
            SmallButton(
              text: 'Pokusaj ponovo',
              color: AppColors.primary,
              onTap: onRefresh,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GenericDataTable<OrderResponse>(
            items: state.items,
            columns: [
              ColumnDef.text(
                label: 'Narudzba',
                flex: 1,
                value: (o) => '#${o.id}',
              ),
              ColumnDef<OrderResponse>(
                label: 'Korisnik',
                flex: 3,
                cellBuilder: (o) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.userFullName,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      o.userEmail,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ColumnDef.text(
                label: 'Ukupno',
                flex: 2,
                value: (o) => '${o.totalAmount.toStringAsFixed(2)} KM',
              ),
              ColumnDef.text(
                label: 'Datum',
                flex: 2,
                value: (o) =>
                    DateFormat('dd.MM.yyyy HH:mm').format(o.purchaseDate),
              ),
              ColumnDef<OrderResponse>(
                label: 'Status',
                flex: 2,
                cellBuilder: (o) => Align(
                  alignment: Alignment.centerLeft,
                  child: switch (o.status) {
                    OrderStatus.delivered => StatusPill.delivered(),
                    OrderStatus.cancelled => StatusPill.cancelled(),
                    _ => StatusPill.pending(),
                  },
                ),
              ),
              ColumnDef.actions(
                flex: 2,
                builder: (o) => [
                  SmallButton(
                    text: 'Detalji',
                    color: AppColors.primary,
                    onTap: () => onViewDetails(o),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
          hint: Text('Sort', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodySecondary,
          icon: const Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 15,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(
              value: 'date_desc',
              child: Text('Datum (najnovije)'),
            ),
            DropdownMenuItem(
              value: 'date_asc',
              child: Text('Datum (najstarije)'),
            ),
            DropdownMenuItem(value: 'amount_desc', child: Text('Iznos (veci)')),
            DropdownMenuItem(value: 'amount_asc', child: Text('Iznos (manji)')),
            DropdownMenuItem(value: 'status_asc', child: Text('Status (A-Z)')),
            DropdownMenuItem(value: 'status_desc', child: Text('Status (Z-A)')),
            DropdownMenuItem(value: 'user_asc', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(value: 'user_desc', child: Text('Korisnik (Z-A)')),
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
          style: AppTextStyles.bodySecondary,
          icon: const Icon(
            LucideIcons.filter,
            color: AppColors.textMuted,
            size: 15,
          ),
          items: const [
            DropdownMenuItem<OrderStatus?>(value: null, child: Text('Svi')),
            DropdownMenuItem<OrderStatus?>(
              value: OrderStatus.processing,
              child: Text('U obradi'),
            ),
            DropdownMenuItem<OrderStatus?>(
              value: OrderStatus.delivered,
              child: Text('Isporuceno'),
            ),
            DropdownMenuItem<OrderStatus?>(
              value: OrderStatus.cancelled,
              child: Text('Otkazano'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
