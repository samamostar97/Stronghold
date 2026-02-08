import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Supplement category service provider
final supplementCategoryServiceProvider = Provider<SupplementCategoryService>((ref) {
  return SupplementCategoryService(ref.watch(apiClientProvider));
});
/// Supplement category list state provider
final supplementCategoryListProvider = StateNotifierProvider<
    SupplementCategoryListNotifier,
    ListState<SupplementCategoryResponse, SupplementCategoryQueryFilter>>((ref) {
  final service = ref.watch(supplementCategoryServiceProvider);
  return SupplementCategoryListNotifier(service);
});

/// Supplement category list notifier implementation
class SupplementCategoryListNotifier extends ListNotifier<
    SupplementCategoryResponse,
    CreateSupplementCategoryRequest,
    UpdateSupplementCategoryRequest,
    SupplementCategoryQueryFilter> {
  SupplementCategoryListNotifier(SupplementCategoryService service)
      : super(
          service: service,
          initialFilter: SupplementCategoryQueryFilter(),
        );
  @override
  SupplementCategoryQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return SupplementCategoryQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
