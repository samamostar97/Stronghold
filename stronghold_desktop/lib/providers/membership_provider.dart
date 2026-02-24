import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Membership service provider
final membershipServiceProvider = Provider<MembershipService>((ref) {
  return MembershipService(ref.watch(apiClientProvider));
});

/// Provider for user payment history
/// Takes userId as family parameter
final userPaymentsProvider =
    FutureProvider.family<
      PagedResult<MembershipPaymentResponse>,
      UserPaymentsParams
    >((ref, params) async {
      final service = ref.watch(membershipServiceProvider);
      return service.getPayments(params.userId, params.filter);
    });

/// Parameters for userPaymentsProvider
class UserPaymentsParams {
  final int userId;
  final MembershipQueryFilter filter;

  const UserPaymentsParams({required this.userId, required this.filter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPaymentsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          filter.pageNumber == other.filter.pageNumber &&
          filter.pageSize == other.filter.pageSize &&
          filter.search == other.filter.search &&
          filter.orderBy == other.filter.orderBy;

  @override
  int get hashCode =>
      userId.hashCode ^
      filter.pageNumber.hashCode ^
      filter.pageSize.hashCode ^
      filter.search.hashCode ^
      filter.orderBy.hashCode;
}

/// Check if a user has active membership using backend membership status source.
final userHasActiveMembershipProvider = FutureProvider.family<bool, int>((
  ref,
  userId,
) async {
  final service = ref.watch(membershipServiceProvider);
  try {
    return await service.hasActiveMembership(userId);
  } catch (_) {
    return false;
  }
});

/// Membership operations notifier for assign/revoke
class MembershipOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final MembershipService _service;

  MembershipOperationsNotifier(this._service)
    : super(const AsyncValue.data(null));

  /// Assign membership to a user
  Future<void> assignMembership(AssignMembershipRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _service.assignMembership(request);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Revoke a user's membership
  Future<void> revokeMembership(int userId) async {
    state = const AsyncValue.loading();
    try {
      await _service.revokeMembership(userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Membership operations provider
final membershipOperationsProvider =
    StateNotifierProvider<MembershipOperationsNotifier, AsyncValue<void>>((
      ref,
    ) {
      final service = ref.watch(membershipServiceProvider);
      return MembershipOperationsNotifier(service);
    });

/// Active members notifier — paged list of users with active memberships
class ActiveMembersNotifier
    extends
        StateNotifier<
          ListState<ActiveMemberResponse, ActiveMemberQueryFilter>
        > {
  final MembershipService _service;

  ActiveMembersNotifier(this._service)
    : super(ListState(filter: ActiveMemberQueryFilter(pageSize: 8))) {
    load();
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getActiveMembers(state.filter);
      state = state.copyWithData(result);
    } catch (e) {
      state = state.copyWithError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> setSearch(String? search) async {
    final normalizedSearch = search ?? '';
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      search: normalizedSearch,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = state.filter.copyWith(pageNumber: page);
    state = state.copyWithFilter(newFilter);
    await load();
  }
}

/// Active members provider
final activeMembersProvider =
    StateNotifierProvider.autoDispose<
      ActiveMembersNotifier,
      ListState<ActiveMemberResponse, ActiveMemberQueryFilter>
    >((ref) {
      final service = ref.watch(membershipServiceProvider);
      return ActiveMembersNotifier(service);
    });
