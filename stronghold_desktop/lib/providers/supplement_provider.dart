import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Supplement service provider
final supplementServiceProvider = Provider<SupplementService>((ref) {
  return SupplementService(ref.watch(apiClientProvider));
});

/// Category service provider (for dropdown)
final categoryServiceProvider = Provider<SupplementCategoryService>((ref) {
  return SupplementCategoryService(ref.watch(apiClientProvider));
});

/// Supplier service provider (for dropdown)
final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(ref.watch(apiClientProvider));
});

/// Categories for dropdown (loads all with large page size)
final categoriesDropdownProvider = FutureProvider<List<SupplementCategoryResponse>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  final filter = SupplementCategoryQueryFilter(pageSize: 100);
  final result = await service.getAll(filter);
  return result.items;
});

/// Suppliers for dropdown (loads all with large page size)
final suppliersDropdownProvider = FutureProvider<List<SupplierResponse>>((ref) async {
  final service = ref.watch(supplierServiceProvider);
  final filter = SupplierQueryFilter(pageSize: 100);
  final result = await service.getAll(filter);
  return result.items;
});

/// Supplement list state provider
final supplementListProvider = StateNotifierProvider<
    SupplementListNotifier,
    ListState<SupplementResponse, SupplementQueryFilter>>((ref) {
  final service = ref.watch(supplementServiceProvider);
  return SupplementListNotifier(service);
});

/// Supplement list notifier implementation
class SupplementListNotifier extends ListNotifier<
    SupplementResponse,
    CreateSupplementRequest,
    UpdateSupplementRequest,
    SupplementQueryFilter> {
  final SupplementService _supplementService;

  SupplementListNotifier(SupplementService service)
      : _supplementService = service,
        super(
          service: service,
          initialFilter: SupplementQueryFilter(),
        );

  @override
  SupplementQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return SupplementQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }

  /// Upload image for a supplement
  Future<void> uploadImage(int supplementId, String filePath) async {
    await _supplementService.uploadImage(supplementId, filePath);
    await refresh();
  }

  /// Delete image for a supplement
  Future<void> deleteImage(int supplementId) async {
    await _supplementService.deleteImage(supplementId);
    await refresh();
  }
}
