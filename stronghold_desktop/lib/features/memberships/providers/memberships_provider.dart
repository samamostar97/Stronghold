import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/memberships_repository.dart';
import '../models/user_membership_response.dart';

// Active memberships

class ActiveMembershipsFilter {
  final int pageNumber;
  final String? search;

  const ActiveMembershipsFilter({this.pageNumber = 1, this.search});

  ActiveMembershipsFilter copyWith({int? pageNumber, String? search}) {
    return ActiveMembershipsFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class ActiveMembershipsFilterNotifier extends Notifier<ActiveMembershipsFilter> {
  @override
  ActiveMembershipsFilter build() => const ActiveMembershipsFilter();

  void update(ActiveMembershipsFilter filter) => state = filter;
}

final activeMembershipsFilterProvider =
    NotifierProvider<ActiveMembershipsFilterNotifier, ActiveMembershipsFilter>(
        ActiveMembershipsFilterNotifier.new);

final activeMembershipsProvider =
    FutureProvider.autoDispose<PagedUserMembershipResponse>((ref) async {
  final filter = ref.watch(activeMembershipsFilterProvider);
  final repo = ref.read(membershipsRepositoryProvider);
  return repo.getActiveMemberships(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});

// Membership history

class MembershipHistoryFilter {
  final int pageNumber;
  final String? search;
  final String? statusFilter;

  const MembershipHistoryFilter({
    this.pageNumber = 1,
    this.search,
    this.statusFilter,
  });

  MembershipHistoryFilter copyWith({
    int? pageNumber,
    String? search,
    String? statusFilter,
  }) {
    return MembershipHistoryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      statusFilter: statusFilter,
    );
  }
}

class MembershipHistoryFilterNotifier
    extends Notifier<MembershipHistoryFilter> {
  @override
  MembershipHistoryFilter build() => const MembershipHistoryFilter();

  void update(MembershipHistoryFilter filter) => state = filter;
}

final membershipHistoryFilterProvider =
    NotifierProvider<MembershipHistoryFilterNotifier, MembershipHistoryFilter>(
        MembershipHistoryFilterNotifier.new);

final membershipHistoryProvider =
    FutureProvider.autoDispose<PagedUserMembershipResponse>((ref) async {
  final filter = ref.watch(membershipHistoryFilterProvider);
  final repo = ref.read(membershipsRepositoryProvider);
  return repo.getMembershipHistory(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: filter.statusFilter,
  );
});
