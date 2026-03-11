import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

@freezed
abstract class UserResponse with _$UserResponse {
  const factory UserResponse({
    required int id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phone,
    String? address,
    String? profileImageUrl,
    required String role,
    required int level,
    required int xp,
    required int totalGymMinutes,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

@freezed
abstract class PagedUserResponse with _$PagedUserResponse {
  const factory PagedUserResponse({
    required List<UserResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedUserResponse;

  factory PagedUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedUserResponseFromJson(json);
}
