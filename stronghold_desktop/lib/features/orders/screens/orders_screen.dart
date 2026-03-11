import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/orders_provider.dart';
import '../widgets/orders_table.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(ordersFilterProvider.notifier).update(OrdersFilter(
        search: value.isEmpty ? null : value,
        statusFilter: ref.read(ordersFilterProvider).statusFilter,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final filter = ref.watch(ordersFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with search
          Row(
            children: [
              Expanded(
                child: Text('Narudzbe', style: AppTextStyles.h2),
              ),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi narudzbe...',
                    hintStyle: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppColors.sidebar,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Table
          ordersAsync.when(
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(
              onRetry: () => ref.invalidate(ordersProvider),
            ),
            data: (data) {
              return OrdersTable(
                orders: data.items,
                currentPage: data.currentPage,
                totalPages: data.totalPages,
                onPageChanged: (page) {
                  ref.read(ordersFilterProvider.notifier).update(
                      filter.copyWith(pageNumber: page));
                },
                showStatusFilter: true,
                selectedStatus: filter.statusFilter,
                onStatusFilterChanged: (status) {
                  ref.read(ordersFilterProvider.notifier).update(OrdersFilter(
                    search: filter.search,
                    statusFilter: status,
                  ));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({required VoidCallback onRetry}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Greska pri ucitavanju narudzbi', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Pokusaj ponovo',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
