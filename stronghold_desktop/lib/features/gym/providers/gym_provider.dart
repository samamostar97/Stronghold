import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gym_repository.dart';
import '../models/gym_visit_response.dart';

// Active visits (no pagination)
final activeVisitsProvider =
    FutureProvider.autoDispose<List<GymVisitResponse>>((ref) async {
  final repo = ref.read(gymRepositoryProvider);
  return repo.getActiveVisits();
});

// Visit history
class VisitHistoryFilter {
  final int pageNumber;
  final String? search;

  const VisitHistoryFilter({this.pageNumber = 1, this.search});

  VisitHistoryFilter copyWith({int? pageNumber, String? search}) {
    return VisitHistoryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class VisitHistoryFilterNotifier extends Notifier<VisitHistoryFilter> {
  @override
  VisitHistoryFilter build() => const VisitHistoryFilter();

  void update(VisitHistoryFilter filter) => state = filter;
}

final visitHistoryFilterProvider =
    NotifierProvider<VisitHistoryFilterNotifier, VisitHistoryFilter>(
        VisitHistoryFilterNotifier.new);

final visitHistoryProvider =
    FutureProvider.autoDispose<PagedGymVisitResponse>((ref) async {
  final filter = ref.watch(visitHistoryFilterProvider);
  final repo = ref.read(gymRepositoryProvider);
  return repo.getVisitHistory(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});
