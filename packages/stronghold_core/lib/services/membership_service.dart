import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/filters/active_member_query_filter.dart';
import '../models/responses/active_member_response.dart';
import '../models/responses/membership_payment_response.dart';
import '../models/requests/assign_membership_request.dart';
import '../models/filters/membership_query_filter.dart';

/// Membership service for managing user memberships
class MembershipService {
  final ApiClient _client;
  static const String _path = '/api/memberships';

  MembershipService(this._client);

  /// Assign a membership to a user
  Future<void> assignMembership(AssignMembershipRequest request) async {
    await _client.post<void>(_path, body: request.toJson(), parser: (_) {});
  }

  /// Revoke a user's membership
  Future<void> revokeMembership(int userId) async {
    await _client.patch<void>('$_path?id=$userId', parser: (_) {});
  }

  /// Check whether a user currently has an active membership
  Future<bool> hasActiveMembership(int userId) async {
    return _client.get<bool>(
      '$_path/$userId/is-active',
      parser: (json) => json as bool,
    );
  }

  /// Get payment history for a user
  Future<PagedResult<MembershipPaymentResponse>> getPayments(
    int userId,
    MembershipQueryFilter filter,
  ) async {
    final queryParams = filter.toQueryParameters();

    return _client.get<PagedResult<MembershipPaymentResponse>>(
      '$_path/$userId/history',
      queryParameters: queryParams,
      parser: (json) => PagedResult.fromJson(
        json,
        (item) => MembershipPaymentResponse.fromJson(item),
      ),
    );
  }

  /// Get paged list of users with active memberships
  Future<PagedResult<ActiveMemberResponse>> getActiveMembers(
    ActiveMemberQueryFilter filter,
  ) async {
    return _client.get<PagedResult<ActiveMemberResponse>>(
      '$_path/active-members',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json,
        (item) => ActiveMemberResponse.fromJson(item),
      ),
    );
  }
}
