import 'package:freezed_annotation/freezed_annotation.dart';

part 'eligible_member_response.freezed.dart';
part 'eligible_member_response.g.dart';

@freezed
abstract class EligibleMemberResponse with _$EligibleMemberResponse {
  const factory EligibleMemberResponse({
    required int userId,
    required String userFullName,
    required String membershipPackageName,
  }) = _EligibleMemberResponse;

  factory EligibleMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$EligibleMemberResponseFromJson(json);
}
