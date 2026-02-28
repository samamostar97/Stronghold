import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Seminar service provider
final seminarServiceProvider = Provider<SeminarService>((ref) {
  return SeminarService(ref.watch(apiClientProvider));
});

/// Seminar list state provider
final seminarListProvider =
    StateNotifierProvider<
      SeminarListNotifier,
      ListState<SeminarResponse, SeminarQueryFilter>
    >((ref) {
      final service = ref.watch(seminarServiceProvider);
      return SeminarListNotifier(service);
    });

/// Seminar list notifier implementation
class SeminarListNotifier
    extends
        ListNotifier<
          SeminarResponse,
          CreateSeminarRequest,
          UpdateSeminarRequest,
          SeminarQueryFilter
        > {
  final SeminarService _seminarService;

  SeminarListNotifier(SeminarService service)
    : _seminarService = service,
      super(
        getAll: service.getAll,
        create: service.create,
        update: service.update,
        delete: service.delete,
        initialFilter: SeminarQueryFilter(),
      );
  @override
  SeminarQueryFilter createFilterCopy({
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

  Future<void> setStatus(String? status) async {
    final normalized = status ?? '';
    final nextFilter = state.filter.copyWith(pageNumber: 1, status: normalized);

    state = state.copyWithFilter(nextFilter);
    await load();
  }

  Future<void> cancelSeminar(int seminarId) async {
    await _seminarService.cancelSeminar(seminarId);
    await refresh();
  }
}
