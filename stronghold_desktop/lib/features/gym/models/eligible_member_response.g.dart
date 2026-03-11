// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eligible_member_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EligibleMemberResponse _$EligibleMemberResponseFromJson(
  Map<String, dynamic> json,
) => _EligibleMemberResponse(
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String,
  membershipPackageName: json['membershipPackageName'] as String,
);

Map<String, dynamic> _$EligibleMemberResponseToJson(
  _EligibleMemberResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'membershipPackageName': instance.membershipPackageName,
};
