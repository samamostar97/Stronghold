import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/staff_repository.dart';
import '../models/staff_response.dart';

final staffRepositoryProvider = Provider((ref) => StaffRepository());

class StaffFilter {
  final int pageNumber;
  final String? search;
  final String? staffType;

  const StaffFilter({
    this.pageNumber = 1,
    this.search,
    this.staffType,
  });

  StaffFilter copyWith({
    int? pageNumber,
    String? search,
    String? staffType,
    bool clearStaffType = false,
  }) {
    return StaffFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      staffType: clearStaffType ? null : (staffType ?? this.staffType),
    );
  }
}

class StaffFilterNotifier extends Notifier<StaffFilter> {
  @override
  StaffFilter build() => const StaffFilter();

  void update(StaffFilter filter) => state = filter;
}

final staffFilterProvider =
    NotifierProvider<StaffFilterNotifier, StaffFilter>(StaffFilterNotifier.new);

final staffListProvider = FutureProvider.autoDispose<PagedStaffResponse>((ref) async {
  final repo = ref.read(staffRepositoryProvider);
  final filter = ref.watch(staffFilterProvider);

  return repo.getStaff(
    pageNumber: filter.pageNumber,
    search: filter.search,
    staffType: filter.staffType,
  );
});
