import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_membership_response.freezed.dart';
part 'user_membership_response.g.dart';

@freezed
abstract class UserMembershipResponse with _$UserMembershipResponse {
  const factory UserMembershipResponse({
    required int id,
    required int userId,
    required String userFullName,
    required int membershipPackageId,
    required String membershipPackageName,
    required double membershipPackagePrice,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
    required DateTime createdAt,
  }) = _UserMembershipResponse;

  factory UserMembershipResponse.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipResponseFromJson(json);
}

@freezed
abstract class PagedUserMembershipResponse with _$PagedUserMembershipResponse {
  const factory PagedUserMembershipResponse({
    required List<UserMembershipResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedUserMembershipResponse;

  factory PagedUserMembershipResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedUserMembershipResponseFromJson(json);
}
