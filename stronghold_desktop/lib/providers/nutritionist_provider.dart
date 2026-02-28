import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Nutritionist service provider
final nutritionistServiceProvider = Provider<NutritionistService>((ref) {
  return NutritionistService(ref.watch(apiClientProvider));
});

/// Nutritionist list state provider
final nutritionistListProvider =
    StateNotifierProvider<
      NutritionistListNotifier,
      ListState<NutritionistResponse, NutritionistQueryFilter>
    >((ref) {
      final service = ref.watch(nutritionistServiceProvider);
      return NutritionistListNotifier(service);
    });

/// Total nutritionist count (lightweight, fetches 1 item for totalCount).
final nutritionistCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(nutritionistServiceProvider);
  final result = await service.getAll(NutritionistQueryFilter(pageSize: 1));
  return result.totalCount;
});

/// Nutritionist list notifier implementation
class NutritionistListNotifier
    extends
        ListNotifier<
          NutritionistResponse,
          CreateNutritionistRequest,
          UpdateNutritionistRequest,
          NutritionistQueryFilter
        > {
  NutritionistListNotifier(NutritionistService service)
    : super(
        getAll: service.getAll,
        create: service.create,
        update: service.update,
        delete: service.delete,
        initialFilter: NutritionistQueryFilter(),
      );
  @override
  NutritionistQueryFilter createFilterCopy({
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
