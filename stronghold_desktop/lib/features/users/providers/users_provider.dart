import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/users_repository.dart';
import '../models/leaderboard_response.dart';
import '../models/user_response.dart';

class UsersFilter {
  final int pageNumber;
  final String? search;

  const UsersFilter({
    this.pageNumber = 1,
    this.search,
  });

  UsersFilter copyWith({
    int? pageNumber,
    String? search,
  }) {
    return UsersFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class UsersFilterNotifier extends Notifier<UsersFilter> {
  @override
  UsersFilter build() => const UsersFilter();

  void update(UsersFilter filter) => state = filter;
}

final usersFilterProvider =
    NotifierProvider<UsersFilterNotifier, UsersFilter>(UsersFilterNotifier.new);

final usersListProvider =
    FutureProvider.autoDispose<PagedUserResponse>((ref) async {
  final repo = ref.read(usersRepositoryProvider);
  final filter = ref.watch(usersFilterProvider);

  return repo.getUsers(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});

// Leaderboard
class LeaderboardFilter {
  final int pageNumber;
  final String? search;

  const LeaderboardFilter({
    this.pageNumber = 1,
    this.search,
  });

  LeaderboardFilter copyWith({
    int? pageNumber,
    String? search,
  }) {
    return LeaderboardFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class LeaderboardFilterNotifier extends Notifier<LeaderboardFilter> {
  @override
  LeaderboardFilter build() => const LeaderboardFilter();

  void update(LeaderboardFilter filter) => state = filter;
}

final leaderboardFilterProvider =
    NotifierProvider<LeaderboardFilterNotifier, LeaderboardFilter>(
        LeaderboardFilterNotifier.new);

final leaderboardProvider =
    FutureProvider.autoDispose<PagedLeaderboardResponse>((ref) async {
  final repo = ref.read(usersRepositoryProvider);
  final filter = ref.watch(leaderboardFilterProvider);

  return repo.getLeaderboard(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});
