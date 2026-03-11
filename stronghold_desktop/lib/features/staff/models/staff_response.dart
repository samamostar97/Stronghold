import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_response.freezed.dart';
part 'staff_response.g.dart';

@freezed
abstract class StaffResponse with _$StaffResponse {
  const factory StaffResponse({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    required String staffType,
    required bool isActive,
  }) = _StaffResponse;

  factory StaffResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffResponseFromJson(json);
}

@freezed
abstract class PagedStaffResponse with _$PagedStaffResponse {
  const factory PagedStaffResponse({
    required List<StaffResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedStaffResponse;

  factory PagedStaffResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedStaffResponseFromJson(json);
}
