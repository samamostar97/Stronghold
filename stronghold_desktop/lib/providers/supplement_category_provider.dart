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
          getAll: service.getAll,
          create: service.create,
          update: service.update,
          delete: service.delete,
          initialFilter: SupplementCategoryQueryFilter(),
        );
  @override
  SupplementCategoryQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    final normalizedSearch = search ?? state.filter.search;
    return state.filter.copyWith(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: normalizedSearch,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
