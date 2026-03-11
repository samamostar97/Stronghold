import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_package_response.freezed.dart';
part 'membership_package_response.g.dart';

@freezed
abstract class MembershipPackageResponse with _$MembershipPackageResponse {
  const factory MembershipPackageResponse({
    required int id,
    required String name,
    String? description,
    required double price,
    required DateTime createdAt,
  }) = _MembershipPackageResponse;

  factory MembershipPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$MembershipPackageResponseFromJson(json);
}

@freezed
abstract class PagedMembershipPackageResponse with _$PagedMembershipPackageResponse {
  const factory PagedMembershipPackageResponse({
    required List<MembershipPackageResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedMembershipPackageResponse;

  factory PagedMembershipPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedMembershipPackageResponseFromJson(json);
}
