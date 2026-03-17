import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seminars_repository.dart';
import '../models/seminar_response.dart';

final seminarsRepositoryProvider = Provider((ref) => SeminarsRepository());

class SeminarsFilter {
  final int pageNumber;
  final String? search;

  const SeminarsFilter({this.pageNumber = 1, this.search});

  SeminarsFilter copyWith({int? pageNumber, String? search}) {
    return SeminarsFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class SeminarsFilterNotifier extends Notifier<SeminarsFilter> {
  @override
  SeminarsFilter build() => const SeminarsFilter();

  void update(SeminarsFilter filter) => state = filter;
}

final seminarsFilterProvider =
    NotifierProvider<SeminarsFilterNotifier, SeminarsFilter>(
        SeminarsFilterNotifier.new);

class SeminarHistoryFilterNotifier extends Notifier<SeminarsFilter> {
  @override
  SeminarsFilter build() => const SeminarsFilter();

  void update(SeminarsFilter filter) => state = filter;
}

final seminarHistoryFilterProvider =
    NotifierProvider<SeminarHistoryFilterNotifier, SeminarsFilter>(
        SeminarHistoryFilterNotifier.new);

// Upcoming seminars
final seminarsProvider =
    FutureProvider.autoDispose<PagedSeminarResponse>((ref) async {
  final repo = ref.read(seminarsRepositoryProvider);
  final filter = ref.watch(seminarsFilterProvider);

  return repo.getSeminars(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'upcoming',
    orderDescending: false,
  );
});

// Completed seminars
final seminarHistoryProvider =
    FutureProvider.autoDispose<PagedSeminarResponse>((ref) async {
  final repo = ref.read(seminarsRepositoryProvider);
  final filter = ref.watch(seminarHistoryFilterProvider);

  return repo.getSeminars(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'completed',
    orderDescending: true,
  );
});
