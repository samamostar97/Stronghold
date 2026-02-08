import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Supplier service provider
final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(ref.watch(apiClientProvider));
});
/// Supplier list state provider
final supplierListProvider = StateNotifierProvider<
    SupplierListNotifier,
    ListState<SupplierResponse, SupplierQueryFilter>>((ref) {
  final service = ref.watch(supplierServiceProvider);
  return SupplierListNotifier(service);
});

/// Supplier list notifier implementation
class SupplierListNotifier extends ListNotifier<
    SupplierResponse,
    CreateSupplierRequest,
    UpdateSupplierRequest,
    SupplierQueryFilter> {
  SupplierListNotifier(SupplierService service)
      : super(
          service: service,
          initialFilter: SupplierQueryFilter(),
        );
  @override
  SupplierQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return SupplierQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
