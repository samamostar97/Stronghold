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
      super(service: service, initialFilter: SeminarQueryFilter());
  @override
  SeminarQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null
        ? state.filter.search
        : (search.isEmpty ? null : search);
    return SeminarQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
      isCancelled: state.filter.isCancelled,
      status: state.filter.status,
    );
  }

  Future<void> setStatus(String? status) async {
    final normalized = (status == null || status.isEmpty) ? null : status;
    final nextFilter = SeminarQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
      status: normalized,
    );

    state = state.copyWithFilter(nextFilter);
    await load();
  }

  Future<void> cancelSeminar(int seminarId) async {
    await _seminarService.cancelSeminar(seminarId);
    await refresh();
  }
}
