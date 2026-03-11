// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      xp: (json['xp'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      levelName: json['levelName'] as String,
      totalGymMinutes: (json['totalGymMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'username': instance.username,
      'profileImageUrl': instance.profileImageUrl,
      'xp': instance.xp,
      'level': instance.level,
      'levelName': instance.levelName,
      'totalGymMinutes': instance.totalGymMinutes,
    };

_PagedLeaderboardResponse _$PagedLeaderboardResponseFromJson(
  Map<String, dynamic> json,
) => _PagedLeaderboardResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$PagedLeaderboardResponseToJson(
  _PagedLeaderboardResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
