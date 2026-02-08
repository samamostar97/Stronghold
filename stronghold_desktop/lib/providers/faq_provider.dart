import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// FAQ service provider
final faqServiceProvider = Provider<FaqService>((ref) {
  return FaqService(ref.watch(apiClientProvider));
});
/// FAQ list state provider
final faqListProvider = StateNotifierProvider<
    FaqListNotifier,
    ListState<FaqResponse, FaqQueryFilter>>((ref) {
  final service = ref.watch(faqServiceProvider);
  return FaqListNotifier(service);
});

/// FAQ list notifier implementation
class FaqListNotifier extends ListNotifier<
    FaqResponse,
    CreateFaqRequest,
    UpdateFaqRequest,
    FaqQueryFilter> {
  FaqListNotifier(FaqService service)
      : super(
          service: service,
          initialFilter: FaqQueryFilter(),
        );
  @override
  FaqQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return FaqQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
