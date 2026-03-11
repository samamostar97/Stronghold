import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_response.freezed.dart';
part 'leaderboard_response.g.dart';

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    required int userId,
    required String fullName,
    required String username,
    String? profileImageUrl,
    required int xp,
    required int level,
    required String levelName,
    required int totalGymMinutes,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

@freezed
abstract class PagedLeaderboardResponse with _$PagedLeaderboardResponse {
  const factory PagedLeaderboardResponse({
    required List<LeaderboardEntry> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedLeaderboardResponse;

  factory PagedLeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedLeaderboardResponseFromJson(json);
}
