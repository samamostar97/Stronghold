import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Membership service provider
final membershipServiceProvider = Provider<MembershipService>((ref) {
  return MembershipService(ref.watch(apiClientProvider));
});

/// Provider for user payment history
/// Takes userId as family parameter
final userPaymentsProvider = FutureProvider.family<PagedResult<MembershipPaymentResponse>, UserPaymentsParams>(
  (ref, params) async {
    final service = ref.watch(membershipServiceProvider);
    return service.getPayments(params.userId, params.filter);
  },
);

/// Parameters for userPaymentsProvider
class UserPaymentsParams {
  final int userId;
  final MembershipQueryFilter filter;

  const UserPaymentsParams({
    required this.userId,
    required this.filter,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPaymentsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          filter.pageNumber == other.filter.pageNumber &&
          filter.pageSize == other.filter.pageSize;

  @override
  int get hashCode => userId.hashCode ^ filter.pageNumber.hashCode ^ filter.pageSize.hashCode;
}

/// Check if a user has active membership (any payment with endDate > now)
final userHasActiveMembershipProvider = FutureProvider.family<bool, int>((ref, userId) async {
  final service = ref.watch(membershipServiceProvider);
  try {
    final result = await service.getPayments(userId, MembershipQueryFilter(pageSize: 10));
    final now = DateTime.now();
    return result.items.any((payment) => payment.endDate.isAfter(now));
  } catch (_) {
    return false;
  }
});

/// Membership operations notifier for assign/revoke
class MembershipOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final MembershipService _service;

  MembershipOperationsNotifier(this._service) : super(const AsyncValue.data(null));

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
final membershipOperationsProvider = StateNotifierProvider<MembershipOperationsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(membershipServiceProvider);
  return MembershipOperationsNotifier(service);
});
